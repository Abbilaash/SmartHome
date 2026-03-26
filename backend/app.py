from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# In-memory sample data
home_data = {
    "rooms": {
        "1": {
            "id": "1",
            "name": "living_room",
            "devices": {
                "light": {"id": "light", "type": "light", "status": "off"},
                "fan": {"id": "fan", "type": "fan", "status": "off"},
                "ac": {"id": "ac", "type": "ac", "status": "off"}
            }
        },
        "2": {
            "id": "2",
            "name": "bedroom",
            "devices": {
                "light": {"id": "light", "type": "light", "status": "off"},
                "fan": {"id": "fan", "type": "fan", "status": "off"}
            }
        },
        "3": {
            "id": "3",
            "name": "kitchen",
            "devices": {
                "light": {"id": "light", "type": "light", "status": "off"},
                "exhaust": {"id": "exhaust", "type": "fan", "status": "off"}
            }
        }
    }
}

VALID_STATUS = {"on", "off"}

def get_room_by_name(room_name: str):
    room_name = room_name.strip().lower().replace(" ", "_")
    for room in home_data["rooms"].values():
        if room["name"] == room_name:
            return room
    return None


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "message": "SmartHome backend is running"
    }), 200


@app.route("/home/rooms", methods=["GET"])
def get_all_rooms():
    rooms = [
        {"id": room["id"], "name": room["name"]}
        for room in home_data["rooms"].values()
    ]
    return jsonify({
        "count": len(rooms),
        "rooms": rooms
    }), 200


@app.route("/home/rooms/<room_id>", methods=["GET"])
def get_room_devices(room_id):
    room = home_data["rooms"].get(room_id)

    if not room:
        return jsonify({"error": "Room not found"}), 404

    return jsonify({
        "room_id": room["id"],
        "room_name": room["name"],
        "devices": list(room["devices"].values())
    }), 200


@app.route("/home/rooms/<room_id>/<device_id>/<status>", methods=["POST"])
def update_device_status(room_id, device_id, status):
    room = home_data["rooms"].get(room_id)

    if not room:
        return jsonify({"error": "Room not found"}), 404

    device = room["devices"].get(device_id)

    if not device:
        return jsonify({"error": "Device not found"}), 404

    status = status.lower()
    if status not in VALID_STATUS:
        return jsonify({"error": "Invalid status. Use 'on' or 'off'"}), 400

    device["status"] = status

    return jsonify({
        "message": "Device status updated successfully",
        "room_id": room_id,
        "room_name": room["name"],
        "device": device
    }), 200


@app.route("/assistant/command", methods=["POST"])
def assistant_command():
    data = request.get_json(silent=True) or {}
    command = str(data.get("command", "")).strip().lower()

    if not command:
        return jsonify({"error": "Command is required"}), 400

    # Example supported commands:
    # "turn on light in living room"
    # "turn off fan in bedroom"

    words = command.split()

    if len(words) < 6 or words[0] != "turn" or words[1] not in VALID_STATUS or "in" not in words:
        return jsonify({
            "error": "Unsupported command format",
            "example": "turn on light in living room"
        }), 400

    action = words[1]
    in_index = words.index("in")

    device_id = "_".join(words[2:in_index]).strip()
    room_name = "_".join(words[in_index + 1:]).strip()

    if not device_id or not room_name:
        return jsonify({
            "error": "Could not parse device or room from command"
        }), 400

    room = get_room_by_name(room_name)
    if not room:
        return jsonify({"error": "Room not found"}), 404

    device = room["devices"].get(device_id)
    if not device:
        return jsonify({"error": "Device not found in that room"}), 404

    device["status"] = action

    return jsonify({
        "message": "Assistant command executed successfully",
        "parsed_command": {
            "room": room["name"],
            "device": device_id,
            "status": action
        },
        "device": device
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)