from flask import Flask, request, jsonify, send_file, render_template
from werkzeug.utils import secure_filename
import joblib
import numpy as np
import pandas as pd

lm1, ct1, hdb4 = joblib.load('lm_api.pkl')
app = Flask(__name__)

model_list = ['lm1']

#new_towns = ['BUKIT TIMAH', 'CENTRAL AREA']
#storeys = [1, 11]
#new_df = pd.DataFrame(data = {'town': new_towns, 'storey':storeys})

# get request parameters should contain town and storey arguments
# curl -G -d 'town=QUEENSTOWN' -d 'storey=1' http://127.0.0.1:5000/prediction
@app.route("/prediction", methods=["GET"])
def make_prediction():
    town = request.args.get('town')
    storey = request.args.get('storey')
    new_df = pd.DataFrame.from_records([(town, storey)], 
                                       columns=['town', 'storey'])
    return jsonify(f"{lm1.predict(ct1.transform(new_df))[0]:.3f}")

# get request DATA should contain a json string with town and storey keys
#curl -X GET -H "Content-type: application/json" -H "Accept: application/json" \
# -d '{"town": ["SENGKANG", "ANG MO KIO"], "storey": [1, 2]}' \
# http://127.0.0.1:5000/predictions
@app.route("/predictions", methods=["GET", "POST"])
def make_predictions():
    new_data = pd.DataFrame(request.get_json())
    preds = lm1.predict(ct1.transform(new_data))
    pred_string = [f'{x:.3f}'for x in preds]
    return jsonify(pred_string)
    #return "No!"
    
# curl -o temp.png  http://127.0.0.1:5000/plot -v
@app.route("/plot")
def return_plot():
    return send_file('test2.png')

#curl -F model=@test_upload.txt http://127.0.0.1:5000/upload -v
@app.route("/upload", methods=["POST"])
def upload_model():
    f = request.files['model']
    #print(f.filename)
    f.save(f"{secure_filename(f.filename)}")
    model_list.append(f.filename)
    return render_template('uploaded.html', fname=f.filename)

@app.route("/list_models", methods=["GET"])
def list_models():
    return render_template('model_list.html', models=model_list)
    
