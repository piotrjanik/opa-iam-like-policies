package rules

import data.policies

check_resource[policy] {
    resource := policies[p].resources[r]
    keys := [ k | resource[k] ]
    input_resource_subset := { k:v  | resource[k]; input.resource[k]=v}
    resource = input_resource_subset
    policies[p] = policy
}