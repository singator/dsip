import dash, io, base64, requests
import dash_bootstrap_components as dbc
from dash.dependencies import Input, Output, State
from dash import Dash, html, dcc, dash_table
import plotly.express as px
import pandas as pd

app = dash.Dash(external_stylesheets=[dbc.themes.BOOTSTRAP])

df = pd.read_csv('hdb_data.csv')
hdb = df.iloc[:, 2:].groupby(by=['flat_type', 'date']).mean('ppsqm')
hdb = hdb.reset_index()
url1 = 'http://flask_model:5000/predictions'

row1 = html.Div(
    [
        dbc.Row(
            [
                dbc.Col(html.Div(
                [html.P('Select the flats you wish to consider:'),

                dcc.Dropdown(id='choose_flat', 
                options=['1 ROOM', '2 ROOM', '3 ROOM', '4 ROOM', '5 ROOM', 
                'EXECUTIVE', 'MULTI-GENERATION'], value = ['4 ROOM'], 
                multi=True, clearable=True ), 

                html.Br(),

                html.P('Select the date range:'), 

                dcc.DatePickerRange(id='date_picks', 
                display_format = 'YYYY-MM-DD', 
                start_date='2017-01-01', end_date='2022-02-28',
                initial_visible_month='2022-02-28')],

                style={'height': '500px', 
                       'padding': '5px 10px',
                       'background-color': 'SkyBlue'}), width=4),

                dbc.Col(dcc.Graph(id='line_graph'), width=8)
            ]

        ),
    ]
)

row2 = html.Div(
    [
        dbc.Row(
            [
                dbc.Col(html.Div(
                [dcc.Upload( 
                id='upload-data', 
                children=html.Div([ 'Drag and Drop or ', 
                html.A('Select File') ], 
                style={
                    'width': '80%',
                    'height': '60px',
                    'lineHeight': '60px',
                    'borderWidth': '1px',
                    'borderStyle': 'dashed',
                    'borderRadius': '5px',
                    'textAlign': 'center',
                    'margin': '10px' 
                    }), 
                multiple=False
                )],

                style={'padding': '5px 10px',
                       'background-color': 'SkyBlue'}), width=4),

                dbc.Col(html.Div(id='upload-data-contents', 
                style={'marginLeft': 'auto', 'marginRight':'auto', 
                       'textAlign': 'center'}), 
                width=7)
            ]

        ),
    ]
)

app.layout = dbc.Container( 
    [html.H1('Plotting price by month'),
    row1, 
    html.Br(),
    html.H1('Batch predictions'),
    row2,
    html.Br(), 
    html.H1('Help pages'),
    dcc.Markdown("""
    As mentioned earlier, plotly and dash are written by the same company.
    Dash is built on top of Flask, which we encountered last week. The 
    datacamp course that you worked on only covered dash; in this 
    app we also use a package that allows us to call upon the bootstrap theme.

    Using dash requires a little more html knowledge and in particular more 
    knowledge of css styling. 

    Here are some useful pages to bookmark that will help with dash and 
    css.

    * The [dash documentation](https://dash.plotly.com/) page contains lots of 
    examples, and code snippets that you can re-use.
        * In particular, take a look at the [page](https://dash.plotly.com/datatable) on DataTables. This element
          allows incredible customisation of a displayed table.
    * The [dash bootstrap components](http://dash-bootstrap-components.opensource.faculty.ai/) 
        package provides us with easy layout management. The gallery of examples is
        not large: [three here](http://dash-bootstrap-components.opensource.faculty.ai/examples/) 
        and a few more on [github](https://github.com/facultyai/dash-bootstrap-components/tree/main/examples).
        There is also a nice theme explorer for this package
        [here](https://hellodash.pythonanywhere.com/) (click on the "Change
        Theme" button on the left).
    * To understand more about css (cascading style sheets), go through some of
      these [pages by the Mozilla foundation](https://developer.mozilla.org/en-US/docs/Web/CSS).
    """)

    ]
)

@app.callback(Output('line_graph', 'figure'), 
              Input('choose_flat', 'value'),
              Input('date_picks', 'start_date'),
              Input('date_picks', 'end_date'))
def make_line_graph(flat_types, date1, date2):
    hdb_sub = hdb[hdb.flat_type.isin(flat_types)]
    hdb_sub = hdb_sub[hdb_sub.date.between(date1, date2)]
    fig = px.line(hdb_sub, x='date', y='ppsqm', line_group='flat_type', 
                markers=True, 
                color='flat_type', labels={'date':'Date', 'ppsqm':'SGD', 
                                           'flat_type':'Flat Type'}, 
                title='Price per sq. metres of HDB resale flats.' )
    return fig

@app.callback(Output('upload-data-contents', 'children'),
             Input('upload-data', 'contents'))
def display_data(u_contents):
    if u_contents is not None:
        content_type, content_string = u_contents.split(',')

        decoded = base64.b64decode(content_string)
        in_df = pd.read_csv(io.StringIO(decoded.decode('utf-8')))
        in_dict = in_df.to_dict('list')
        print(in_dict)
        r1 = requests.post(url1, json=in_dict)
        in_df['predictions'] = pd.to_numeric(pd.Series(r1.json()))

        return dash_table.DataTable(
            in_df.to_dict('records'),
            [{'name': i, 'id': i} for i in in_df.columns],
            sort_action= 'native',
            filter_action='native', page_size=2,
            style_header={'background-color': 'DimGray',
                          'color':'white'},
            style_data_conditional=[
            {
            'if': {
                'column_id': 'predictions',
            },
            'backgroundColor': 'SandyBrown',
            'color': 'white'
            }]
        )

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0')
