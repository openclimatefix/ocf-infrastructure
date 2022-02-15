import requests
from nowcasting_datamodel.models import Forecast
from datetime import datetime, timedelta, timezone

api_url = 'http://0.0.0.0'


def test_api():
    """ Check that the api is up """

    r = requests.get(f'{api_url}/docs')
    assert r.status_code == 200


def test_api_national():
    """ Check that the api is up """

    r = requests.get(f'{api_url}/v0/forecasts/GB/pv/national')
    assert r.status_code == 200
    forecast = Forecast(**r.json())
    assert forecast.forecast_creation_time > datetime.now().replace(tzinfo=timezone.utc) - timedelta(minutes=5)
