package rules

import data.policies

check_principal[policy] {
    input_principal := input.principal
    policies[p].principal.role[_] = input_principal.role
    policies[p].principal.department = input_principal.department
    policies[p] = policy
}

check_principal[policy] {
    input_principal := input.principal
    policies[p].notPrincipal.role[_] != input_principal.role
    policies[p] = policy
}

check_principal[policy] {
    input_principal := input.principal
    policies[p].notPrincipal.department != input_principal.department
    policies[p] = policy  
}