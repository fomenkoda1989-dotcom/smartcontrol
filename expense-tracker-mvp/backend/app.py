"""
Main Flask application for expense tracker backend.
Provides REST API endpoints for receipt upload, listing, and statistics.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import json
import uuid
from datetime import datetime
from werkzeug.utils import secure_filename
from services.ocr_service import OCRService
from services.ai_parser import AIParser

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter Web

# Configuration
UPLOAD_FOLDER = 'uploads'
DATA_FILE = 'data/receipts.json'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Initialize services
ocr_service = OCRService()
ai_parser = AIParser()

# Ensure required directories exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs('data', exist_ok=True)


def allowed_file(filename):
    """Check if file extension is allowed."""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def load_receipts():
    """Load receipts from JSON file."""
    if not os.path.exists(DATA_FILE):
        return []
    with open(DATA_FILE, 'r') as f:
        return json.load(f)


def save_receipts(receipts):
    """Save receipts to JSON file."""
    with open(DATA_FILE, 'w') as f:
        json.dump(receipts, f, indent=2)


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({'status': 'healthy', 'service': 'expense-tracker-api'})


@app.route('/receipt/upload', methods=['POST'])
def upload_receipt():
    """
    Upload a receipt image and process it.

    Returns structured receipt data with OCR and AI parsing.
    """
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    if not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file type. Allowed: png, jpg, jpeg, gif'}), 400

    try:
        # Generate unique filename
        receipt_id = str(uuid.uuid4())
        filename = secure_filename(file.filename)
        ext = filename.rsplit('.', 1)[1].lower()
        saved_filename = f"{receipt_id}.{ext}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], saved_filename)

        # Save file
        file.save(filepath)

        # Step 1: OCR - Extract text from image
        ocr_text = ocr_service.extract_text(filepath)

        # Step 2: AI Parsing - Convert text to structured data
        parsed_data = ai_parser.parse_receipt(ocr_text)

        # Create receipt record
        receipt = {
            'id': receipt_id,
            'filename': saved_filename,
            'uploaded_at': datetime.now().isoformat(),
            'store': parsed_data['store'],
            'date': parsed_data['date'],
            'items': parsed_data['items'],
            'total': parsed_data['total'],
            'ocr_text': ocr_text  # Store raw OCR for debugging
        }

        # Save to database
        receipts = load_receipts()
        receipts.append(receipt)
        save_receipts(receipts)

        # Return without OCR text in response (too verbose)
        response = {k: v for k, v in receipt.items() if k != 'ocr_text'}
        return jsonify(response), 201

    except Exception as e:
        return jsonify({'error': f'Processing failed: {str(e)}'}), 500


@app.route('/receipts', methods=['GET'])
def get_receipts():
    """
    Get all receipts with basic information.

    Returns list of receipts sorted by date (newest first).
    """
    try:
        receipts = load_receipts()

        # Sort by upload date, newest first
        receipts.sort(key=lambda x: x.get('uploaded_at', ''), reverse=True)

        # Return simplified list (without full items and OCR text)
        simplified = [
            {
                'id': r['id'],
                'store': r['store'],
                'date': r['date'],
                'total': r['total'],
                'uploaded_at': r['uploaded_at'],
                'item_count': len(r.get('items', []))
            }
            for r in receipts
        ]

        return jsonify(simplified), 200

    except Exception as e:
        return jsonify({'error': f'Failed to load receipts: {str(e)}'}), 500


@app.route('/receipts/<receipt_id>', methods=['GET'])
def get_receipt_detail(receipt_id):
    """
    Get detailed information for a specific receipt.

    Returns full receipt data including all items.
    """
    try:
        receipts = load_receipts()

        # Find receipt by ID
        receipt = next((r for r in receipts if r['id'] == receipt_id), None)

        if not receipt:
            return jsonify({'error': 'Receipt not found'}), 404

        # Return without OCR text
        response = {k: v for k, v in receipt.items() if k != 'ocr_text'}
        return jsonify(response), 200

    except Exception as e:
        return jsonify({'error': f'Failed to load receipt: {str(e)}'}), 500


@app.route('/stats/month', methods=['GET'])
def get_monthly_stats():
    """
    Get spending statistics for the current month.

    Returns total spent and breakdown by category.
    """
    try:
        receipts = load_receipts()

        # Get current month/year
        now = datetime.now()
        current_month = now.month
        current_year = now.year

        # Filter receipts from current month
        month_receipts = []
        for r in receipts:
            try:
                # Parse receipt date (format: YYYY-MM-DD)
                receipt_date = datetime.fromisoformat(r['date'])
                if receipt_date.month == current_month and receipt_date.year == current_year:
                    month_receipts.append(r)
            except (ValueError, KeyError):
                # Skip receipts with invalid dates
                continue

        # Calculate total spent
        total_spent = sum(float(r['total']) for r in month_receipts)

        # Calculate category breakdown
        category_totals = {}
        for receipt in month_receipts:
            for item in receipt.get('items', []):
                category = item.get('category', 'other')
                price = float(item.get('price', 0))
                category_totals[category] = category_totals.get(category, 0) + price

        # Format category breakdown for response
        categories = [
            {'category': cat, 'amount': amount}
            for cat, amount in category_totals.items()
        ]
        categories.sort(key=lambda x: x['amount'], reverse=True)

        return jsonify({
            'month': current_month,
            'year': current_year,
            'total_spent': round(total_spent, 2),
            'receipt_count': len(month_receipts),
            'categories': categories
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to calculate stats: {str(e)}'}), 500


if __name__ == '__main__':
    print("Starting Expense Tracker API...")
    print("Server running on http://localhost:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)
