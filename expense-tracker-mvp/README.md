# Expense Tracker MVP

A Flutter Web application for personal expense tracking based on receipt photos. Upload receipt images, automatically extract and categorize expenses, and view spending analytics.

## Features

- **Receipt Upload**: Upload receipt photos and automatically extract data
- **Receipt Management**: View all your receipts with store, date, and total
- **Receipt Details**: See itemized breakdown with automatic categorization
- **Monthly Summary**: Track spending by category with visual breakdown
- **OCR Processing**: Extract text from receipt images (mock implementation)
- **AI Parsing**: Convert receipt text to structured data (mock implementation)

## Tech Stack

### Frontend
- **Flutter Web**: Cross-platform UI framework
- **Material Design 3**: Modern, clean UI
- **HTTP**: RESTful API communication
- **File Picker**: Image upload support

### Backend
- **Flask 3.1.0**: Python web framework
- **Flask-CORS 5.0.0**: Cross-origin resource sharing
- **Pillow 11.0.0**: Image processing (Python 3.13 compatible)
- **JSON Storage**: Simple file-based data persistence

## Project Structure

```
expense-tracker-mvp/
├── backend/                    # Python Flask API
│   ├── app.py                 # Main API server
│   ├── requirements.txt       # Python dependencies
│   ├── services/              # Business logic
│   │   ├── ocr_service.py    # OCR text extraction (mock)
│   │   └── ai_parser.py      # AI parsing service (mock)
│   ├── uploads/               # Uploaded receipt images
│   └── data/                  # JSON data storage
│       └── receipts.json      # Receipt database
│
└── frontend/                   # Flutter Web app
    ├── lib/
    │   ├── main.dart          # App entry point
    │   ├── models/            # Data models
    │   │   ├── receipt.dart
    │   │   └── monthly_stats.dart
    │   ├── services/          # API communication
    │   │   └── api_service.dart
    │   └── screens/           # UI screens
    │       ├── upload_page.dart
    │       ├── receipt_list_page.dart
    │       ├── receipt_detail_page.dart
    │       └── monthly_summary_page.dart
    ├── web/                   # Web assets
    │   ├── index.html
    │   └── manifest.json
    └── pubspec.yaml           # Flutter dependencies
```

## API Endpoints

### Backend REST API

```
GET  /health                 - Health check
POST /receipt/upload         - Upload and process receipt image
GET  /receipts               - Get all receipts (simplified)
GET  /receipts/{id}          - Get detailed receipt data
GET  /stats/month            - Get current month statistics
```

### API Request/Response Examples

**POST /receipt/upload**
```bash
curl -X POST http://localhost:5001/receipt/upload \
  -F "file=@receipt.jpg"
```

Response:
```json
{
  "id": "uuid",
  "store": "Walmart",
  "date": "2026-01-22",
  "total": "45.67",
  "items": [
    {"name": "Milk", "price": "4.99", "category": "groceries"}
  ]
}
```

**GET /receipts**
```json
[
  {
    "id": "uuid",
    "store": "Walmart",
    "date": "2026-01-22",
    "total": "45.67",
    "item_count": 5
  }
]
```

**GET /stats/month**
```json
{
  "month": 1,
  "year": 2026,
  "total_spent": 234.56,
  "receipt_count": 8,
  "categories": [
    {"category": "groceries", "amount": 150.00},
    {"category": "household", "amount": 50.00}
  ]
}
```

## Setup and Installation

### Prerequisites

- **Python 3.13+**: Backend runtime
- **Flutter 3.0+**: Frontend framework
- **Git**: Version control

### Backend Setup

> **Note**: This project requires Python 3.13+ and uses updated package versions (Flask 3.1.0, Pillow 11.0.0) for compatibility. On macOS/Linux, use `python3` and `pip3` commands.

1. Navigate to backend directory:
```bash
cd expense-tracker-mvp/backend
```

2. Create virtual environment (recommended):
```bash
python3 -m venv venv

# On macOS/Linux:
source venv/bin/activate

# On Windows:
venv\Scripts\activate
```

3. Install dependencies:
```bash
# On macOS/Linux:
pip3 install -r requirements.txt

# On Windows:
pip install -r requirements.txt
```

4. Run the server:
```bash
# On macOS/Linux:
python3 app.py

# On Windows:
python app.py
```

The backend will start on `http://localhost:5001`

> **Note**: Changed from default port 5000 to 5001 to avoid conflicts with macOS AirPlay Receiver

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd expense-tracker-mvp/frontend
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Run the web app:
```bash
flutter run -d chrome
```

Or build for production:
```bash
flutter build web
```

The frontend will open in Chrome at `http://localhost:port`

## Usage

1. **Start Backend**: Run `python3 app.py` (or `python app.py` on Windows) in the backend directory
2. **Start Frontend**: Run `flutter run -d chrome` in the frontend directory
3. **Upload Receipt**: Click "Upload Receipt" and select an image
4. **View Receipts**: Navigate to "My Receipts" to see all uploads
5. **View Details**: Click on any receipt to see itemized breakdown
6. **Check Summary**: View "Monthly Summary" for spending statistics

## Current Implementation: Mock Services

### OCR Service (Mock)

Location: [backend/services/ocr_service.py](backend/services/ocr_service.py)

Currently returns sample receipt text with realistic data. To integrate real OCR:

**Option 1: Google Cloud Vision**
```python
from google.cloud import vision

client = vision.ImageAnnotatorClient()
with open(image_path, 'rb') as f:
    content = f.read()
image = vision.Image(content=content)
response = client.text_detection(image=image)
text = response.text_annotations[0].description
```

**Option 2: Tesseract OCR (Open Source)**
```python
import pytesseract
from PIL import Image

image = Image.open(image_path)
text = pytesseract.image_to_string(image)
```

**Option 3: AWS Textract**
```python
import boto3

textract = boto3.client('textract')
with open(image_path, 'rb') as f:
    response = textract.detect_document_text(Document={'Bytes': f.read()})
text = '\n'.join([item['Text'] for item in response['Blocks']])
```

### AI Parser (Mock)

Location: [backend/services/ai_parser.py](backend/services/ai_parser.py)

Currently uses regex-based parsing for mock OCR output. To integrate real AI:

**Option 1: OpenAI GPT-4**
```python
import openai

response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{
        "role": "system",
        "content": "Parse this receipt into JSON..."
    }, {
        "role": "user",
        "content": ocr_text
    }]
)
parsed_data = json.loads(response.choices[0].message.content)
```

**Option 2: Anthropic Claude**
```python
import anthropic

client = anthropic.Anthropic(api_key="...")
message = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    messages=[{"role": "user", "content": f"Parse this receipt: {ocr_text}"}]
)
parsed_data = json.loads(message.content[0].text)
```

## Categorization Logic

The AI parser automatically categorizes items into:

- **groceries**: Food items (milk, bread, produce, etc.)
- **household**: Cleaning supplies, paper products
- **alcohol**: Beer, wine, spirits
- **other**: Everything else

Location: [backend/services/ai_parser.py:_categorize_item()](backend/services/ai_parser.py)

Extend the keyword lists or integrate AI for better categorization.

## Configuration

### Backend Configuration

Edit [backend/app.py](backend/app.py):

```python
# Change upload folder location
UPLOAD_FOLDER = 'uploads'

# Change data storage location
DATA_FILE = 'data/receipts.json'

# Change max file size (in bytes)
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB
```

### Frontend Configuration

Edit [frontend/lib/services/api_service.dart](frontend/lib/services/api_service.dart):

```dart
// Change backend URL
static const String baseUrl = 'http://localhost:5001';
```

For production, update this to your deployed backend URL.

## Development Notes

### Architecture Decisions

1. **JSON File Storage**: Simple file-based storage for MVP. For production, migrate to PostgreSQL, MongoDB, or similar.

2. **Mock AI Services**: Structured to allow easy replacement with real services. All AI logic is isolated in service classes.

3. **No Authentication**: MVP doesn't include user auth. Add Firebase Auth, JWT, or OAuth for multi-user support.

4. **CORS Enabled**: Backend allows all origins for development. Restrict in production:
   ```python
   CORS(app, origins=['https://your-domain.com'])
   ```

5. **Material Design**: Using default Material 3 theme. Customize colors in [frontend/lib/main.dart](frontend/lib/main.dart).

### Extending the MVP

**Add Database Support**:
- Replace JSON storage with SQLAlchemy + PostgreSQL
- Create proper database schema for receipts and items

**Add User Authentication**:
- Implement JWT-based auth
- Add user registration/login screens
- Associate receipts with user accounts

**Improve AI Accuracy**:
- Integrate real OCR service (Google Vision, Textract)
- Use GPT-4 or Claude for parsing
- Train custom model on receipt data

**Add More Features**:
- Date range filtering
- Export to CSV/PDF
- Receipt image preview
- Edit receipt data manually
- Search and filter receipts

## Troubleshooting

### Backend Issues

**Port already in use**:
```bash
# By default, the app uses port 5001 to avoid conflicts with macOS AirPlay Receiver (port 5000)

# Check what's using a port (macOS/Linux):
lsof -i :5001

# Kill process on port (if needed):
lsof -ti:5001 | xargs kill -9

# To disable AirPlay Receiver on macOS:
# System Settings → AirDrop & Handoff → AirPlay Receiver → Off

# Or change port in app.py to another port:
app.run(port=8000)
```

**Module not found**:
```bash
# Reinstall dependencies
# On macOS/Linux:
pip3 install -r requirements.txt

# On Windows:
pip install -r requirements.txt
```

**pip command not found (macOS/Linux)**:
```bash
# Use pip3 instead of pip
pip3 install -r requirements.txt

# Or update pip (optional)
pip3 install --upgrade pip
```

**CORS errors**:
- Ensure Flask-CORS is installed
- Check that backend is running
- Verify frontend API URL matches backend port

### Frontend Issues

**Flutter not found**:
```bash
# Install Flutter: https://flutter.dev/docs/get-started/install
flutter doctor
```

**Dependencies error**:
```bash
# Clear cache and reinstall
flutter clean
flutter pub get
```

**Web support not enabled**:
```bash
flutter config --enable-web
```

**API connection failed**:
- Ensure backend is running on port 5001
- Check browser console for CORS errors
- Verify API URL in [api_service.dart](frontend/lib/services/api_service.dart)

## License

This is an MVP project. Use as needed for learning or as a foundation for production apps.

## Next Steps

1. **Deploy Backend**: Use Heroku, AWS, or Google Cloud
2. **Deploy Frontend**: Use Firebase Hosting, Netlify, or Vercel
3. **Integrate Real AI**: Replace mock services with actual OCR/AI APIs
4. **Add Database**: Migrate from JSON to proper database
5. **Add Auth**: Implement user authentication
6. **Mobile App**: Build native iOS/Android versions using same Flutter codebase
