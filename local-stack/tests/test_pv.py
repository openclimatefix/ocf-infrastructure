
from nowcasting_datamodel.connection import DatabaseConnection, Base_PV
from nowcasting_datamodel.models.pv import PVYieldSQL, PVSystemSQL

db_url = 'postgresql://postgres:postgres@localhost:5433/postgres'


def test_database():
    """ Check that the database is up """

    connection = DatabaseConnection(url=db_url, base=Base_PV,echo=True)
    with connection.get_session() as session:
        _ = session.query(PVSystemSQL).all()


def test_pv_systems():
    """ Check that there are pv systems in the database """

    connection = DatabaseConnection(url=db_url, base=Base_PV,echo=True)
    with connection.get_session() as session:
        pv_systems = session.query(PVSystemSQL).all()
        assert len(pv_systems) > 0


def test_pv_yields():
    """ Check that there are pv data in the database
    
    Warning: This test might not work early in the morning,
    as there seems to be no PV data avaialbe then.
    """

    connection = DatabaseConnection(url=db_url,base=Base_PV,echo=True)
    with connection.get_session() as session:
        pv_yields = session.query(PVYieldSQL).all()
        assert len(pv_yields) > 0
