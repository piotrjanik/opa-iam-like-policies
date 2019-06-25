package rules

import data.policies

default allow = false

allow = false {
    check[_policies]
    check_deny[_policies]
} else = true {
    check[_policies]
    not check_deny[_policies]
}

check[_policies] {
    check_principal[_policies]
    check_resource[_policies]
    check_action[_policies]
}

check_deny[policy] = true {
    policies[p].effect = "Deny"
    policies[p] = policy
}