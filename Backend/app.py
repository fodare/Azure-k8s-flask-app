import requests
import platform
import socket
import os
from flask import Flask, jsonify, make_response

app = Flask(__name__)
base_url = "https://randomuser.me/api/"
session = requests.Session()

random_user_url = "https://randomuser.me/api/?gender="


@app.route("/backendservice/")
def health_check():
    response_object = {
        "Success": True,
        "Message": platform.platform()
    }
    return make_response(jsonify(response_object), 200)


@app.route("/backendservice/user")
def get_random_user():
    """Fetch random user from Random user api"""
    r = session.get(base_url)
    response_objects = {
        "Success": False,
        "Message": ""
    }
    if r.status_code == 200:
        response_objects["Success"] = True
        response_objects["Message"] = r.json()
    else:
        response_objects[
            "Message"] = f'Error fetching user. Recived status code: {r.status_code}'
    return make_response(jsonify(response_objects))


@app.route("/backendservice/gender/<string:gender>")
def get_user_by_gender(gender):
    """Fetch random user based on gender"""
    response_objects = {
        "Success": False,
        "Message": ""
    }
    r = session.get(f'{random_user_url}{gender}')
    if r.status_code == 200:
        response_objects["Success"] = True
        response_objects["Message"] = r.json()
    else:
        response_objects["Message"] = "Error fetching random user."

    return make_response(jsonify(response_objects))


@app.route("/backendservice/user/count/<int:count>")
def get_user_by_count(count):
    """Fetch random user based on count"""
    response_objects = {
        "Success": False,
        "Message": ""
    }
    r = session.get(f'{base_url}?results={count}')
    if r.status_code == 200:
        response_objects["Success"] = True
        response_objects["Message"] = r.json()
    else:
        response_objects[
            "Message"] = f'Error fetching user. Received respose code {r.status_code}'
    return make_response(jsonify(response_objects))


if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5001))
    app.run(debug=True, host='0.0.0.0', port=port)
