import platform
import requests
import datetime
import os
import socket
from flask import Flask, jsonify, make_response

app = Flask(__name__)
base_url = "https://randomuser.me/api/"
session = requests.Session()


def get_host_details():
    """Returns base url for the backend service"""
    host_name = socket.gethostname()
    host_ip_address = socket.getfqdn()
    # base_url = os.environ['backend-service']
    return str(host_name), str(host_ip_address)


@app.route("frontendservice/")
def health_check():
    response_object = {
        "Success": True,
        "Message": platform.platform()
    }
    return make_response(jsonify(response_object), 200)


@app.route("/frontendservice/user")
def fetch_users():
    """
    Calls the backend service to fetch random user.
    """
    response_object = {
        "Success": False,
        "Message": "message"
    }
    r = session.get('http://backendservice:5001/backendservice/user')
    if r.status_code == 200:
        response_object["Success"] = True
        response_object["Message"] = r.json()
    else:
        response_object["Message"] = r.json()
    return make_response(jsonify(response_object))


@app.route("/frontendservice/user/gender/<string:gender>")
def fetch_random_user_by_gender(gender):
    """Fetch a user based on gender"""
    hostName, Ip = get_host_details()
    print(f'Machine I p address: {Ip}')
    session.trust_env = False
    r = session.get(
        f'http://backendservice:5001/backendservice/gender/{gender}')
    response_object = {
        "Success": False,
        "Message": "message"
    }
    if r.status_code == 200:
        response_object["Success"] = True
        response_object["Message"] = r.json()
    else:
        response_object["Message"] = "Error fetching user from backend service"

    return make_response(jsonify(response_object))


@app.route("/frontendservice/user/<int:count>")
def fetch_random_user_count(count):
    """Fetch user based on count from the backend service"""
    response_objects = {
        "Success": False,
        "Message": ""
    }
    r = session.get(
        f'http://backendservice:5001/backendservice/user/count/{count}')
    if r.status_code == 200:
        response_objects["Message"] = r.json()
        response_objects["Success"] = True
    else:
        response_objects["Message"] = r.json()

    return make_response(jsonify(response_objects))


if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)

    # Supporting document
