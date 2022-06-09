
from nowcasting_datamodel.connection import DatabaseConnection
from nowcasting_datamodel.models.models import Base_Forecast
from nowcasting_datamodel.models.gsp import GSPYieldSQL, LocationSQL

db_url = 'postgresql://postgres:postgres@localhost:5432/postgres'


def test_database():
    """ Check that the database is up """

    connection = DatabaseConnection(url=db_url, base=Base_Forecast,echo=True)
    with connection.get_session() as session:
        _ = session.query(LocationSQL).all()


def test_gsp_systems():
    """ Check that there are pv systems in the database """

    connection = DatabaseConnection(url=db_url, base=Base_Forecast,echo=True)
    with connection.get_session() as session:
        gsps = session.query(LocationSQL).all()
        assert len(gsps) > 0


def test_gsp_yields():
    """
    Check that there are gsp yields in the database
    """

    connection = DatabaseConnection(url=db_url, base=Base_Forecast,echo=True)
    with connection.get_session() as session:
        gsp_yields = session.query(GSPYieldSQL).all() # Errors because a column is VARCHAR when it should be Float maybe?
        assert len(gsp_yields) > 0
