# Fine grained access control for your (micro)services

Services, microservices, serverless functions.. whichever you are dealing with you get a great chance to implement some kind of security.
First authentication, so that you know who is interacting with it.
I doubt you would write your own authentication mechanism with user repository for each service, microservices or lambda. Quite likely you would prefer integrating with some kind of Identity Provider through OAuth2/OpenID/SAML/etc or just leverage cloud provider services like AWS IAM/K8s tokens.
Nowadays, authentication can be easily delegated to an external service which we trust.

But what can you do for authorizartion?
Imagine you have got tens, houndreds of services and each have to grant or deny access to a particular API endpoint depending on quite complex logic.

This article is about solving that problem by building centralized and highly scalable mechanism for access decision.

To achieve that we will use Open Policy Agent! Yey!

## First things first - Let's define problem we want to solve

Let's assume we have two microservices and their REST APIs look as follow:

- mushrooms:
  - /api/mushrooms
    - GET - returns list of all mushrooms
    - POST - adds single mushrooms
- books
  - /api/books
    - GET - returns list of all books
    - POST - adds single

We have also three kinds of users who will interact with our API:

- Papa Smurf
  - belongs to forrest department
  - has SMURF and GURU roles assigned
- Clumsy Smurf
  - belongs to forrest department
  - has SMURF role assigned
- Anonymous

**Here is the goal**:

- Mushrooms:
  - Only **GURU** can add(POST) **RED** mushrooms
  - Every **SMURF** can add any kind of mushroom except **RED** one
  - Everyone can get list of collected mushrooms
- Books:
  - Any **SMURF** can add books or get a list of books
  - Any **SMURF** can remove a book as long as it counts less than 100 pages.
  - Only **GURU** can remove any book.

Now, let's do it in a Cloud Native style!

## Plan

I hope at some point you came across Role Based Access Control(RBAC) from Kubernetes or IAM Policies from AWS. What both have in common? Well, each provides an engine to make an access control decision based on some inputs and data.

Let's take a closer:

Sample IAM Policy for S3 Buckets:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": {"AWS": ["arn:aws:iam::ACCOUNT:root"]},
      "Effect": "Allow",
      "Action": ["s3:List*","s3:Get*"],
      "Resource": [
        "arn:aws:s3:::BUCKET",
        "arn:aws:s3:::BUCKET/*"
      ]
    }
  ]
}
```

Sample RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: roleName
rules:
  - apiGroups: [""]
    resources:
      - nodes
      - nodes/proxy
      - services
      - endpoints
      - pods
    verbs: ["get", "list", "watch"]
```

In both examples we have three elements which give us a great flexibility on how access decision can be made:

- action/verbs - defines what kind of action is being done, is it read only action or read write or something else? you name it
- actor/user/principal - in general who is interacting with an API
- resource - what is being read and/or changed

In our case we will implement similar solution for our microservices/services/functions by building **custom policies** with **Open Policy Agent**.

This is how we gonna use:

1. Principal - will be defined as a json object:

    ```json
    {
        "name": "Clumsy Smurf",
        "role": "smurf",
        "department": "forest",
        "age": 10
    }
    ```

2. Resource - yet another json objects, but this time can be different per resource:

    ```json
    {"name":"mushrooms", "color": "red"}
    // or
    {"name":"books", "pages": 1000}
    ```

TBC