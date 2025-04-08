import cv2
from pyzbar.pyzbar import decode
import numpy as np
import json
import firebase_admin
from firebase_admin import credentials, firestore

# Firebase Initialization
cred = credentials.Certificate("firebase-adminsdk.json")  # Path to Firebase Admin SDK JSON file
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load product database
PRODUCTS_FILE = "products.json"
def load_products():
    try:
        with open(PRODUCTS_FILE, "r") as file:
            return json.load(file)
    except FileNotFoundError:
        print(f"Error: {PRODUCTS_FILE} not found.")
        return {}
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON format in {PRODUCTS_FILE}.")
        return {}

# Initialize products and carts
products = load_products()
carts = {}
products_on_shelf = {}
current_user = None
user_validated = False  # Flag to track user validation

# Function to generate cart summary
def generate_cart_summary(user_id):
    cart_summary = {
        "user": user_id,
        "items": [
            {
                "product": k,
                "price": v["price"],
                "discount": v.get("discount", 0),
                "image_url": v.get("image_url", "")  # Include image URL
            } for k, v in carts[user_id].items()
        ],
        "total_cost": sum(
            v["price"] - (v["price"] * v.get("discount", 0) / 100)
            for v in carts[user_id].values()
        )
    }
    return cart_summary


# Function to update Firestore with cart summary
def update_firestore(user_id):
    if user_id in carts:
        cart_summary = generate_cart_summary(user_id)
        try:
            db.collection("users").document(user_id).set(cart_summary)
            print(f"Updated Firestore for user {user_id} with data: {cart_summary}")
        except Exception as e:
            print(f"Error updating Firestore for user {user_id}: {e}")

# Function to validate QR code data
def validate_user(qr_data):
    try:
        print(f"Validating QR code with data: {qr_data}")  # Debugging line
        user_query = db.collection('users').where('session_token', '==', qr_data).get()
        if user_query:
            user_id = user_query[0].id
            # Use set with merge=True to avoid overwriting other fields
            db.collection('users').document(user_id).set({'validated': True}, merge=True)
            print(f"User {user_id} validated and updated in Firestore.")
            return user_id
        else:
            print(f"No user found for session_token: {qr_data}")  # Debugging line
    except Exception as e:
        print(f"Error validating user: {e}")
    return None


# Initialize webcam
cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("Error: Camera could not be opened.")
    exit()

print("Monitoring the shelf... Press 'q' to quit.")

while True:
    # Capture frame from the camera
    ret, frame = cap.read()
    if not ret:
        print("Error: Unable to capture video.")
        break

    # Convert to grayscale for better QR detection
    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Decode QR codes
    qr_codes = decode(gray_frame)
    current_shelf_items = set()

    for qr in qr_codes:
        qr_data = qr.data.decode('utf-8').strip()

        # If no user has been validated, validate the user
        if not user_validated:
            user_id = validate_user(qr_data)
            if user_id:
                current_user = user_id
                carts[current_user] = carts.get(current_user, {})
                user_validated = True
                print(f"User {current_user} logged in.")
                # Simulate application pop-up and redirection
                print(f"Welcome, {current_user}! Redirecting to cart summary...")
            continue

        # Validate product in the database (for shelf monitoring)
        if qr_data not in products:
            print(f"Warning: {qr_data} not found in the product database.")
            continue

        current_shelf_items.add(qr_data)

        # Check if the product is back on the shelf
        if qr_data not in products_on_shelf:
            products_on_shelf[qr_data] = True
            if qr_data in carts[current_user]:
                del carts[current_user][qr_data]
                products[qr_data]["stock"] += 1
                print(f"Removed from cart: {qr_data}")
            print(f"{qr_data} is now on the shelf.")

        # Draw bounding box around QR code
        points = qr.polygon
        if len(points) >= 4:
            pts = np.array([(point.x, point.y) for point in points], dtype=np.int32)
            pts = pts.reshape((-1, 1, 2))
            cv2.polylines(frame, [pts], isClosed=True, color=(0, 255, 0), thickness=3)

        # Display product details on the frame
        x, y = qr.rect.left, qr.rect.top
        cv2.putText(frame, f"{qr_data} - ₹{products[qr_data]['price']}", 
                    (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

    # Handle products removed from the shelf
    for product_data in list(products_on_shelf.keys()):
        if product_data not in current_shelf_items:
            if product_data not in carts[current_user]:
                carts[current_user][product_data] = products[product_data]
                products[product_data]["stock"] -= 1
                print(f"Added to cart: {product_data} - ₹{products[product_data]['price']}")
            del products_on_shelf[product_data]

    # Update Firestore in real-time
    if current_user:
        update_firestore(current_user)

    # Show the frame
    cv2.imshow("Shelf Monitoring with Cart", frame)

    # Exit loop on 'q' key press
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Cleanup
cap.release()
cv2.destroyAllWindows()
print("Session ended.")
