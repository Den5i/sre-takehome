import time
import json
from flask import Flask
from time import process_time

startTime = time.time()

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/uptime",  methods=['GET'])
def uptime():

    processStart = process_time()
    clockTime = time.strftime('%H:%M:%S')
    currentUptime = str(time.time() - startTime)
    processEnd = process_time()

    requestTime = str(processEnd - processStart)

    Output = {
        "Current Time": clockTime,
        "Application Uptime": currentUptime,
        "Processed in": requestTime
    }

    Result = json.dumps(Output)
    return Result;

if __name__ == "__main__":
    app.run(host='0.0.0.0')
