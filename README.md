# LincolnLife (Flutter)

Flutter front end for the Lincoln Life "Aura" life-insurance needs assistant.
Pairs with the Aura backend (`lincoln-life-backend`).

## Aura chatbot access

- **Front page (guest):** the login screen's Aura badge opens the full assistant
  before sign-in ("Chat with Aura").
- **Inside the app (signed in):** the floating Aura button and the Dashboard /
  Explore / Profile actions open the same assistant.

The chat talks to the backend's `/chat` endpoint on every turn. The backend owns
all math (DIME) and product facts (RAG) — the app renders what Aura returns:

- `reply` + `disclaimer` in the chat,
- guided `options` as tappable chips (shown only when the backend sends them;
  numeric questions take free text),
- the final estimate carried through to the Results and Dashboard screens using
  the backend's figures (no local re-computation).

The Term vs. Permanent screen calls `/tradeoffs` for a personalized, RAG-grounded
comparison (Lincoln offers term + IUL + VUL, not whole life).

## Connecting to the backend

The API base URL comes from a dart-define, defaulting to localhost:

```bash
# 1. Run the backend (see lincoln-life-backend): uvicorn main:app --reload  (port 8000)

# 2. Run the app pointing at it:
flutter run --dart-define=AURA_API_BASE_URL=http://localhost:8000

# Defaults if the define is omitted:
#   Android emulator -> http://10.0.2.2:8000  (host alias)
#   other platforms  -> http://localhost:8000
```

If the backend is unreachable, Aura shows a friendly connection message and the
Compare screen falls back to static (accurate) copy.

## Setup

```bash
flutter pub get
flutter run
```
