export interface DynamicField {
  id: string
  key: string
  value: string
}

export interface UploadedFile {
  id: string
  name: string
  displayName: string
  file?: File
  uploadedAt?: string
  size?: number
  url?: string
}

export interface EditalFormData {
  title: string
  description: string
  status: 'open' | 'closed' | 'analyzing'
  mainPDF: UploadedFile | null
  dynamicFields: DynamicField[]
  annexes: UploadedFile[]
  results: UploadedFile[]
}

export interface EditalPayload {
  title: string
  description: string
  status: string
  metadata: Record<string, string>
  files: {
    mainPDF: { name: string; originalName: string } | null
    annexes: Array<{ id: string; name: string; originalName: string }>
    results: Array<{ id: string; name: string; originalName: string }>
  }
}

export interface EditalResponse {
  id: string
  title: string
  description: string
  status: string
  metadata: Record<string, string>
  created_at: string
  updated_at: string
  files: {
    main_pdf?: string
    annexes: Array<{ id: string; name: string; url: string }>
    results: Array<{ id: string; name: string; url: string }>
  }
}
