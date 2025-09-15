from flask import Flask, request, jsonify
import pymysql

app = Flask(__name__)

# 数据库连接配置
def get_db_connection():
    return pymysql.connect(
        host='127.0.0.1',
        user='root',
        password='12345678',
        database='weathernew',
        charset='utf8'
    )

# 获取城市列表 (GET /api/cities)
@app.route('/api/cities', methods=['GET'])
def get_cities():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, city_name, weather, temperature, value FROM cities")
        data = cursor.fetchall()

        # 将数据库数据转换为前端需要的格式（CityWeather）
        cities = []
        for row in data:
            cities.append({
                'id': row[0],           # 数据库字段：id
                'cityName': row[1],     # 数据库字段：city_name
                'weather': row[2],      # 数据库字段：weather
                'temperature': row[3],  # 数据库字段：temperature
                'value': row[4]         # 数据库字段：value
            })

        cursor.close()
        conn.close()
        return jsonify({'code': 0, 'data': cities})  # 返回 JSON 格式数据
    except Exception as e:
        print("获取城市数据失败:", e)
        return jsonify({'code': 500, 'message': '获取城市数据失败'}), 500

# 添加新城市 (POST /api/cities)
@app.route('/api/cities', methods=['POST'])
def add_city():
    try:
        data = request.get_json()  # 获取前端发送的 JSON 数据
        city_name = data.get('cityName')
        weather = data.get('weather', '晴')  # 默认天气
        temperature = data.get('temperature', '20℃-30℃')  # 默认温度
        value = data.get('value', 0)  # 默认值

        if not city_name:
            return jsonify({'code': 400, 'message': '城市名称不能为空'}), 400

        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 检查城市是否已存在
        cursor.execute("SELECT * FROM cities WHERE city_name = %s", (city_name,))
        existing_city = cursor.fetchone()
        
        if existing_city:
            cursor.close()
            conn.close()
            return jsonify({'code': 1, 'message': '城市已存在'}), 409

        # 添加新城市
        cursor.execute(
            "INSERT INTO cities (city_name, weather, temperature, value) VALUES (%s, %s, %s, %s)",
            (city_name, weather, temperature, value)
        )
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'code': 0, 'message': '城市添加成功'})
    except Exception as e:
        print("添加城市失败:", e)
        return jsonify({'code': 500, 'message': '添加城市失败'}), 500

 # 登录接口 (POST /api/login)
@app.route('/api/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        account = data.get('account')
        password = data.get('password')

        if not account or not password:
            return jsonify({'code': 1, 'message': '用户名和密码不能为空'}), 400

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE account = %s", (account,))
        user = cursor.fetchone()

        if not user:
            cursor.close()
            conn.close()
            return jsonify({'code': 1, 'message': '用户不存在'}), 404

        if user[2] != password:
            cursor.close()
            conn.close()
            return jsonify({'code': 2, 'message': '密码错误'}), 401

        cursor.close()
        conn.close()
        return jsonify({'code': 0, 'message': '登录成功'})
    except Exception as e:
        print("登录失败:", e)
        return jsonify({'code': 500, 'message': '服务器内部错误'}), 500

# 注册接口 (POST /api/register)
@app.route('/api/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        account = data.get('account')
        password = data.get('password')

        if not account or not password:
            return jsonify({'code': 1, 'message': '用户名和密码不能为空'}), 400

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE account = %s", (account,))
        existing_user = cursor.fetchone()

        if existing_user:
            cursor.close()
            conn.close()
            return jsonify({'code': 1, 'message': '用户已存在'}), 409

        cursor.execute(
            "INSERT INTO users (account, password) VALUES (%s, %s)",
            (account, password)
        )
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'code': 0, 'message': '注册成功'})
    except Exception as e:
        print("注册失败:", e)
        return jsonify({'code': 500, 'message': '服务器内部错误'}), 500

   # 模拟天气数据
def get_weather_data(city):
    # 模拟当前天气数据
    current_weather = {
        "city": city,
        "currentTemp": 24,
        "feelsLike": 26,
        "windDirection": "西南风",
        "windLevel": 2,
        "weatherDesc": "晴"
    }

    # 模拟逐小时天气预报
    hourly_forecast = [
        {"time": "18:00", "img": "sun", "temp": 29},
        {"time": "21:00", "img": "cloudy", "temp": 28},
        {"time": "00:00", "img": "sun", "temp": 26},
        {"time": "03:00", "img": "rain", "temp": 25},
        {"time": "06:00", "img": "cloudy", "temp": 24},
        {"time": "09:00", "img": "sun", "temp": 27}
    ]

    # 模拟生活指数
    living_index = [
        {"name": "感冒指数", "value": "可能", "tag": "低风险", "tagColor": "#3888FF"},
        {"name": "洗车指数", "value": "较适宜", "tag": "适宜", "tagColor": "#27C281"},
        {"name": "穿衣指数", "value": "短袖", "tag": "舒适", "tagColor": "#27C281"},
        {"name": "紫外线指数", "value": "中等", "tag": "中等", "tagColor": "#FF9C31"},
        {"name": "运动指数", "value": "不适宜", "tag": "注意", "tagColor": "#FF9C31"},
        {"name": "化妆指数", "value": "保湿", "tag": "适宜", "tagColor": "#27C281"}
    ]

    # 模拟未来七天天气预报
    daily_forecast = [
        {"day": "今天", "weather": "晴", "icon": "sun", "high": 32, "low": 24},
        {"day": "周六", "weather": "多云", "icon": "cloudy", "high": 30, "low": 23},
        {"day": "周日", "weather": "小雨", "icon": "rain", "high": 28, "low": 22},
        {"day": "周一", "weather": "小雨", "icon": "rain", "high": 27, "low": 21},
        {"day": "周二", "weather": "阴", "icon": "cloudy", "high": 29, "low": 22},
        {"day": "周三", "weather": "晴", "icon": "sun", "high": 31, "low": 23},
        {"day": "周四", "weather": "晴", "icon": "sun", "high": 33, "low": 24}
    ]

    return current_weather, hourly_forecast, living_index, daily_forecast

# 获取当前天气信息
@app.route('/api/weather/current', methods=['GET'])
def get_current_weather():
    city = request.args.get('city', '北京市')  # 默认城市为北京
    current_weather, _, _, _ = get_weather_data(city)
    return jsonify({'code': 0, 'data': current_weather})

# 获取逐小时天气预报
@app.route('/api/weather/hourly', methods=['GET'])
def get_hourly_forecast():
    city = request.args.get('city', '北京市')  # 默认城市为北京
    _, hourly_forecast, _, _ = get_weather_data(city)
    return jsonify({'code': 0, 'data': hourly_forecast})

# 获取生活指数
@app.route('/api/weather/living-index', methods=['GET'])
def get_living_index():
    city = request.args.get('city', '北京市')  # 默认城市为北京
    _, _, living_index, _ = get_weather_data(city)
    return jsonify({'code': 0, 'data': living_index})

# 获取未来七天天气预报
@app.route('/api/weather/daily', methods=['GET'])
def get_daily_forecast():
    city = request.args.get('city', '北京市')  # 默认城市为北京
    _, _, _, daily_forecast = get_weather_data(city)
    return jsonify({'code': 0, 'data': daily_forecast})

# 获取激活的城市列表 (GET /api/cities/active)
@app.route('/api/cities/active', methods=['GET'])
def get_active_cities():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, city_name, weather, temperature, value, is_active FROM cities WHERE is_active = 1")
        data = cursor.fetchall()

        # 将数据库数据转换为前端需要的格式（CityWeather）
        cities = []
        for row in data:
            cities.append({
                'id': row[0],           # 数据库字段：id
                'cityName': row[1],     # 数据库字段：city_name
                'weather': row[2],      # 数据库字段：weather
                'temperature': row[3],  # 数据库字段：temperature
                'value': row[4],        # 数据库字段：value
                'isActive': row[5]      # 数据库字段：is_active
            })

        cursor.close()
        conn.close()
        return jsonify({'code': 0, 'data': cities})  # 返回 JSON 格式数据
    except Exception as e:
        print("获取激活城市数据失败:", e)
        return jsonify({'code': 500, 'message': '获取激活城市数据失败'}), 500

# 激活城市 (POST /api/cities/activate)
@app.route('/api/cities/activate', methods=['POST'])
def activate_city():
    try:
        data = request.get_json()  # 获取前端发送的 JSON 数据
        city_name = data.get('cityName')

        if not city_name:
            return jsonify({'code': 400, 'message': '城市名称不能为空'}), 400

        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 检查城市是否存在
        cursor.execute("SELECT * FROM cities WHERE city_name = %s", (city_name,))
        existing_city = cursor.fetchone()
        
        if not existing_city:
            cursor.close()
            conn.close()
            return jsonify({'code': 1, 'message': '城市不存在'}), 404
        
        # 检查城市是否已经是激活状态
        if existing_city[5] == 1:  # is_active字段
            cursor.close()
            conn.close()
            return jsonify({'code': 1, 'message': '城市已经是激活状态'}), 409
        
        # 激活城市（将is_active设置为1）
        cursor.execute(
            "UPDATE cities SET is_active = 1, updated_at = CURRENT_TIMESTAMP WHERE city_name = %s",
            (city_name,)
        )
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'code': 0, 'message': '城市激活成功'})
    except Exception as e:
        print("激活城市失败:", e)
        return jsonify({'code': 500, 'message': '激活城市失败'}), 500

# 获取热门城市天气数据 (GET /api/hotcities)
@app.route('/api/hotcities', methods=['GET'])
def get_hot_cities():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM hotcities")
        data = cursor.fetchall()

        # 将数据库数据转换为前端需要的格式
        cities = []
        for row in data:
            city_data = {
                'id': row[0],
                'cityName': row[1],
                'cityDescription': row[2],
                'currentTemp': row[3],
                'feelsLike': row[4],
                'windDirection': row[5],
                'windLevel': row[6],
                'weatherDesc': row[7],
                'hourlyData': [
                    {'time': '18:00', 'temp': row[8]},
                    {'time': '21:00', 'temp': row[9]},
                    {'time': '00:00', 'temp': row[10]},
                    {'time': '03:00', 'temp': row[11]},
                    {'time': '06:00', 'temp': row[12]},
                    {'time': '09:00', 'temp': row[13]}
                ],
                'livingIndex': [
                    {
                        'name': row[14],
                        'value': row[15],
                        'tag': row[16],
                        'tagColor': row[17]
                    },
                    {
                        'name': row[18],
                        'value': row[19],
                        'tag': row[20],
                        'tagColor': row[21]
                    },
                    {
                        'name': row[22],
                        'value': row[23],
                        'tag': row[24],
                        'tagColor': row[25]
                    },
                    {
                        'name': row[26],
                        'value': row[27],
                        'tag': row[28],
                        'tagColor': row[29]
                    },
                    {
                        'name': row[30],
                        'value': row[31],
                        'tag': row[32],
                        'tagColor': row[33]
                    },
                    {
                        'name': row[34],
                        'value': row[35],
                        'tag': row[36],
                        'tagColor': row[37]
                    }
                ],
                'dailyForecast': [
                    {'day': row[38], 'weather': row[39], 'high': row[40], 'low': row[41]},
                    {'day': row[42], 'weather': row[43], 'high': row[44], 'low': row[45]},
                    {'day': row[46], 'weather': row[47], 'high': row[48], 'low': row[49]},
                    {'day': row[50], 'weather': row[51], 'high': row[52], 'low': row[53]},
                    {'day': row[54], 'weather': row[55], 'high': row[56], 'low': row[57]},
                    {'day': row[58], 'weather': row[59], 'high': row[60], 'low': row[61]},
                    {'day': row[62], 'weather': row[63], 'high': row[64], 'low': row[65]}
                ]
            }
            cities.append(city_data)

        cursor.close()
        conn.close()
        return jsonify({'code': 0, 'data': cities})
    except Exception as e:
        print("获取热门城市数据失败:", e)
        return jsonify({'code': 500, 'message': '获取热门城市数据失败'}), 500

# 根据城市名称获取天气数据 (GET /api/hotcities/<city_name>)
@app.route('/api/hotcities/<city_name>', methods=['GET'])
def get_city_weather(city_name):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM hotcities WHERE city_name = %s", (city_name,))
        row = cursor.fetchone()

        if not row:
            cursor.close()
            conn.close()
            return jsonify({'code': 404, 'message': '城市不存在'}), 404

        # 将数据库数据转换为前端需要的格式
        city_data = {
            'id': row[0],
            'cityName': row[1],
            'cityDescription': row[2],
            'currentTemp': row[3],
            'feelsLike': row[4],
            'windDirection': row[5],
            'windLevel': row[6],
            'weatherDesc': row[7],
            'hourlyData': [
                {'time': '18:00', 'temp': row[8]},
                {'time': '21:00', 'temp': row[9]},
                {'time': '00:00', 'temp': row[10]},
                {'time': '03:00', 'temp': row[11]},
                {'time': '06:00', 'temp': row[12]},
                {'time': '09:00', 'temp': row[13]}
            ],
            'livingIndex': [
                {
                    'name': row[14],
                    'value': row[15],
                    'tag': row[16],
                    'tagColor': row[17]
                },
                {
                    'name': row[18],
                    'value': row[19],
                    'tag': row[20],
                    'tagColor': row[21]
                },
                {
                    'name': row[22],
                    'value': row[23],
                    'tag': row[24],
                    'tagColor': row[25]
                },
                {
                    'name': row[26],
                    'value': row[27],
                    'tag': row[28],
                    'tagColor': row[29]
                },
                {
                    'name': row[30],
                    'value': row[31],
                    'tag': row[32],
                    'tagColor': row[33]
                },
                {
                    'name': row[34],
                    'value': row[35],
                    'tag': row[36],
                    'tagColor': row[37]
                }
            ],
            'dailyForecast': [
                {'day': row[38], 'weather': row[39], 'high': row[40], 'low': row[41]},
                {'day': row[42], 'weather': row[43], 'high': row[44], 'low': row[45]},
                {'day': row[46], 'weather': row[47], 'high': row[48], 'low': row[49]},
                {'day': row[50], 'weather': row[51], 'high': row[52], 'low': row[53]},
                {'day': row[54], 'weather': row[55], 'high': row[56], 'low': row[57]},
                {'day': row[58], 'weather': row[59], 'high': row[60], 'low': row[61]},
                {'day': row[62], 'weather': row[63], 'high': row[64], 'low': row[65]}
            ]
        }

        cursor.close()
        conn.close()
        return jsonify({'code': 0, 'data': city_data})
    except Exception as e:
        print("获取城市天气数据失败:", e)
        return jsonify({'code': 500, 'message': '获取城市天气数据失败'}), 500

# 启动后端服务
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)