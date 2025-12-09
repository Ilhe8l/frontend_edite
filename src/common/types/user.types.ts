export interface User {
  id: string
  email: string
  name: string
}

export interface AuthTokens {
  access: string
  refresh: string
}

export interface LoginCredentials {
  email: string
  password: string
}
