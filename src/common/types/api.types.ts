export interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  message?: string
}

export interface EditalMetrics {
  id: string
  title: string
  messageCount: number
  uniqueUsers: number
  lastMessage: string
}

export interface EngagementMetricsResponse {
  total_messages: number
  total_users: number
  total_editals: number
  editals: EditalMetrics[]
}

export interface Message {
  id: string
  userId: string
  userEmail: string
  question: string
  botResponse: string
  timestamp: string
  editalId?: string
}

export interface ConversationSession {
  id: string
  userId: string
  userEmail: string
  startTime: string
  endTime: string
  messageCount: number
  edital?: string
  messages?: ConversationMessage[]
}

export interface ConversationMessage {
  id: string
  role: 'user' | 'bot'
  content: string
  timestamp: string
}

// Re-export types from other files for convenience
export type { User, AuthTokens, LoginCredentials } from './user.types'
export type { 
  DynamicField, 
  UploadedFile, 
  EditalFormData, 
  EditalPayload, 
  EditalResponse 
} from './edital.types'
