import requests
from nowcasting_datamodel.connection import DatabaseConnection
from nowcasting_datamodel.models import MLModelSQL, ForecastSQL, Forecast
from nowcasting_datamodel.read import get_latest_national_forecast
from datetime import datetime, timedelta, timezone

db_url = 'postgresql://postgres:postgres@localhost:5432/postgres'


def test_database():
    """ Check that the database is up """

    connection = DatabaseConnection(url=db_url)
    with connection.get_session() as session:
        _ = session.query(MLModelSQL).all()


def test_forecasts():
    """ Check that there are forecasts in the database """

    connection = DatabaseConnection(url=db_url)
    with connection.get_session() as session:
        forecasts = session.query(ForecastSQL).all()
        assert len(forecasts) > 0


def test_get_latest_national_forecast():
    """ Check that there are the latest national is within the last 5 minutes """

    connection = DatabaseConnection(url=db_url)
    with connection.get_session() as session:
        forecast = get_latest_national_forecast(session=session)
        assert forecast.forecast_creation_time > datetime.now().replace(tzinfo=timezone.utc) - timedelta(minutes=5)
