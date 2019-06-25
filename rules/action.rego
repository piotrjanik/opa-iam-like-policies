package rules

import data.policies


check_action[policy] {
    policies[p] = policy
    policy.action[_] = input.action
}

check_action[policy] {
    policies[p] = policy
    policy.action[_] = "*"
}