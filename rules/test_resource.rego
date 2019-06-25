package rules

test_smurf_can_get_book {
    allow with input as {
        "resource": {"name":"books", "title": "never ending story.."}
    }
}

test_stranger_cannot_access_forest_resources {
    not allow with input as {
        "resource": {"name":"books", "title": "never ending story.."}
    }
}