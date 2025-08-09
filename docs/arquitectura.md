```mermaid
graph TD
graph TD
  subgraph CLIENTE
    A[App Flutter]
  end

  subgraph BACKEND
    B[NestJS en Azure]
  end

  subgraph BBDD
    C[(Base de Datos SQL en Railway)]
    D[(Base de Datos NoSQL en Railway)]
  end

  A -->|HTTP REST API| B
  B -->|Consulta y almacena| C
  B -->|Consulta y almacena| D
```