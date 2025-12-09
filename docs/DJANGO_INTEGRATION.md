# Django Backend Integration Guide

## Overview

This document describes the JSON payload structures and API endpoints that the frontend uses to communicate with the Django backend.

## Base URL Configuration

Set the Django API base URL via environment variable:

\`\`\`bash
NEXT_PUBLIC_DJANGO_API_URL=http://localhost:8000/api
\`\`\`

## API Endpoints

### Editals Management

#### POST /editals/
Create a new edital with metadata and file information.

**Request Payload:**
\`\`\`json
{
  "title": "Edital de Chamada Pública nº 001/2024",
  "description": "Seleção de pesquisadores para projetos...",
  "status": "open",
  "metadata": {
    "Link Externo": "www.exemplo.com",
    "Departamento": "Pesquisa",
    "Contato": "contato@instituicao.gov.br"
  },
  "files": {
    "mainPDF": {
      "name": "Edital-001-2024",
      "originalName": "edital_001_2024.pdf"
    },
    "annexes": [
      {
        "id": "file_001",
        "name": "Anexo-I",
        "originalName": "anexo_i.pdf"
      }
    ],
    "results": [
      {
        "id": "file_002",
        "name": "Resultado-Parcial",
        "originalName": "resultado_parcial.pdf"
      }
    ]
  }
}
\`\`\`

**Response:**
\`\`\`json
{
  "id": "edital_001",
  "title": "Edital de Chamada Pública nº 001/2024",
  "description": "...",
  "status": "open",
  "metadata": {...},
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z",
  "files": {
    "main_pdf": "https://api.exemplo.com/files/edital_001.pdf",
    "annexes": [
      {
        "id": "file_001",
        "name": "Anexo-I",
        "url": "https://api.exemplo.com/files/anexo_i.pdf"
      }
    ],
    "results": [...]
  }
}
\`\`\`

#### GET /editals/
List all editals.

#### GET /editals/{id}/
Get specific edital details.

#### PUT /editals/{id}/
Update edital information.

#### POST /editals/{id}/upload/
Upload files to existing edital.

**Form Data:**
- `file`: File object (binary)
- `type`: 'main' | 'annexe' | 'result'

---

### Metrics Endpoints

#### GET /metrics/engagement/
Get engagement metrics for all editals.

**Response:**
\`\`\`json
{
  "total_messages": 760,
  "total_users": 111,
  "total_editals": 5,
  "editals": [
    {
      "id": "edital_001",
      "title": "Edital de Chamada Pública nº 001/2024",
      "message_count": 245,
      "unique_users": 32,
      "last_message": "2024-01-15"
    }
  ]
}
\`\`\`

#### GET /metrics/messages/
Get messages filtered by edital.

**Query Parameters:**
- `edital_id`: (optional) Filter by specific edital

**Response:**
\`\`\`json
[
  {
    "id": "msg_001",
    "user_id": "user_1",
    "user_email": "maria@example.com",
    "question": "Qual é a data limite para inscrição?",
    "bot_response": "De acordo com o edital, a data limite é 31 de janeiro de 2024.",
    "timestamp": "2024-01-15T14:30:00Z",
    "edital_id": "edital_001"
  }
]
\`\`\`

---

### Conversation History Endpoints

#### GET /conversations/sessions/
Get paginated list of conversation sessions.

**Query Parameters:**
- `limit`: (default: 50) Number of results
- `offset`: (default: 0) Pagination offset
- `email`: (optional) Filter by user email
- `user_id`: (optional) Filter by user ID

**Response:**
\`\`\`json
[
  {
    "id": "sess_001",
    "user_id": "user_1",
    "user_email": "maria.silva@example.com",
    "start_time": "2024-01-15T14:00:00Z",
    "end_time": "2024-01-15T14:35:00Z",
    "message_count": 8,
    "edital": "Edital 001/2024"
  }
]
\`\`\`

#### GET /conversations/sessions/{id}/
Get conversation session details with full message history.

**Response:**
\`\`\`json
{
  "id": "sess_001",
  "user_id": "user_1",
  "user_email": "maria.silva@example.com",
  "start_time": "2024-01-15T14:00:00Z",
  "end_time": "2024-01-15T14:35:00Z",
  "message_count": 8,
  "edital": "Edital 001/2024",
  "messages": [
    {
      "id": "msg_1",
      "role": "user",
      "content": "Qual é a data limite para inscrição no edital?",
      "timestamp": "2024-01-15T14:00:00Z"
    },
    {
      "id": "msg_2",
      "role": "bot",
      "content": "De acordo com o edital, a data limite para inscrição é 31 de janeiro de 2024.",
      "timestamp": "2024-01-15T14:01:00Z"
    }
  ]
}
\`\`\`

---

## Implementation Example

### Creating an Edital

\`\`\`typescript
import { EditalService, type EditalFormInput } from '@/lib/edital-service'

const formData: EditalFormInput = {
  title: 'Edital 001/2024',
  description: 'Descrição do edital...',
  status: 'open',
  mainPDF: {...},
  dynamicFields: [
    { id: '1', key: 'Link Externo', value: 'www.exemplo.com' }
  ],
  annexes: [],
  results: []
}

const response = await EditalService.createEdital(formData)

if (response.success) {
  console.log('Edital criado:', response.data)
} else {
  console.error('Erro:', response.error)
}
\`\`\`

### Fetching Metrics

\`\`\`typescript
import { apiClient } from '@/lib/api-client'

const response = await apiClient.getEngagementMetrics()

if (response.success) {
  const metrics = response.data
  console.log('Total de mensagens:', metrics.total_messages)
}
\`\`\`

---

## Error Handling

All API responses follow this structure:

\`\`\`json
{
  "success": boolean,
  "data": {...},
  "error": "Error message if applicable"
}
\`\`\`

Always check `response.success` before accessing `response.data`.

---

## File Upload Process

1. Create/Update edital record with metadata
2. For each file (main PDF, annexes, results):
   - Upload via FormData to `/editals/{id}/upload/`
   - Backend processes file and regenerates embeddings
   - Updates knowledge base for chatbot

---

## Notes for Django Backend

- All timestamps must be in ISO 8601 format (UTC)
- File uploads should trigger embedding regeneration
- Metadata fields support up to 1000 characters per value
- Support for PDF files only for edital documents
- Implement proper error codes (400, 404, 500) for frontend handling
