# Princess AI

Monorepo with Flutter mobile app and FastAPI backend.

## Structure
- `mobile/` Flutter app
- `backend/` FastAPI API
- `docs/` architecture notes

## Backend
```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```
Swagger: `http://127.0.0.1:8000/docs`

## Flutter
```bash
cd mobile
flutter pub get
flutter run
```
Android emulator uses `http://10.0.2.2:8000`; web/desktop uses `http://127.0.0.1:8000`.
