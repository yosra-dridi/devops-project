from flask import Flask
from flask import request

app = Flask(__name__)


def factorial(number):
    """
    @params: number
        any whole number
    @return: int
        factorial ( $number )
    """
    # Basic conditions
    if not (number >= 0 and isinstance(number, int)):
        print("Input should be a whole number")
        return 1  # returning with exit code 1

    # Base case
    if number == 0:
        return 1

    # main logic
    response = number * factorial(number - 1)
    return response


def count_of_prime_factors(number):
    """
    @params: number
        any integer greater than 1
    @return: int
        total number of prime factors of that number
            1 is not a prime factor
            a prime number has one prime factor
            12 has 3 prime factors -> 2,2,3
    """
    count = 0
    factors = []

    while number % 2 == 0:
        number /= 2
        count += 1
        factors.append(2)

    for i in range(3, int(number**0.5)+2, 2):
        while number % i == 0:
            count += 1
            number /= i
            factors.append(i)

    if number > 1:
        count += 1
        factors.append(number)
    # print("Factors: {}".format(factors))
    return count


@app.route('/')
def healthcheck():
    return "server is running"


@app.route('/factorial', methods=['GET'])
def factorial_route():
    number = int(request.args.get('number'))
    return {"factorial": factorial(number)}


@app.route('/primefactors', methods=['GET'])
def primefactors_route():
    number = int(request.args.get('number'))
    return {"primefactorscount": count_of_prime_factors(number)}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
