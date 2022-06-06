import pytest
import json
from server import factorial, count_of_prime_factors
from server import app

def test_factorial():
    test_cases = {
        0:1,
        1:1,
        5:120
    }

    for key, value in test_cases.items():
        assert factorial(key) == value

def test_count_of_prime_factors():
    test_cases = {
        5:1,
        10:2,
        4:2,
        3:1,
        100:4,
        73:1
    }

    for key, value in test_cases.items():
        assert count_of_prime_factors(key) == value

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_factorial_route(client):
    res = client.get('/factorial?number=5').data
    res_value = json.loads(res).get('factorial')
    assert res_value == 120

def test_primefactors_route(client):
    res = client.get('/primefactors?number=5').data
    res_value = json.loads(res).get('primefactorscount')
    assert res_value == 1