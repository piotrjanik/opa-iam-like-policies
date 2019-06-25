package rules

test_smurf_can_get_book {
    allow with input as {
        "principal": {
            "name": "Random Smurf",
            "role": "smurf",
            "department": "forest",
            "age": 10
        }
    }
}

test_stranger_cannot_access_forest_resources {
    not allow with input as {
        "principal": {
            "name": "Stranger",
            "role": "wizard",
            "department": "whoknows",
            "age": 200
        }
    }
}