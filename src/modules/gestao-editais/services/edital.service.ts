import { apiClient } from '@/common/api/client'
import type { EditalFormData, EditalPayload, EditalResponse } from '@/common/types/edital.types'

export const editalService = {
  formatPayload(formData: EditalFormData): EditalPayload {
    return {
      title: formData.title,
      description: formData.description,
      status: formData.status,
      metadata: formData.dynamicFields.reduce((acc, field) => {
        if (field.key && field.value) {
          acc[field.key] = field.value
        }
        return acc
      }, {} as Record<string, string>),
      files: {
        mainPDF: formData.mainPDF
          ? {
              name: formData.mainPDF.displayName,
              originalName: formData.mainPDF.name,
            }
          : null,
        annexes: formData.annexes.map((f) => ({
          id: f.id,
          name: f.displayName,
          originalName: f.name,
        })),
        results: formData.results.map((f) => ({
          id: f.id,
          name: f.displayName,
          originalName: f.name,
        })),
      },
    }
  },

  async createEdital(formData: EditalFormData): Promise<EditalResponse> {
    const payload = this.formatPayload(formData)
    const edital = await apiClient.post<EditalResponse>('/edital/edital/', payload)

    // Upload files
    const uploadPromises: Promise<any>[] = []

    if (formData.mainPDF?.file) {
      const formDataUpload = new FormData()
      formDataUpload.append('file', formData.mainPDF.file)
      formDataUpload.append('type', 'main')
      uploadPromises.push(
        apiClient.uploadFile(`/edital/edital/${edital.id}/upload/`, formDataUpload)
      )
    }

    formData.annexes.forEach((annexe) => {
      if (annexe.file) {
        const formDataUpload = new FormData()
        formDataUpload.append('file', annexe.file)
        formDataUpload.append('type', 'annexe')
        uploadPromises.push(
          apiClient.uploadFile(`/edital/edital/${edital.id}/upload/`, formDataUpload)
        )
      }
    })

    formData.results.forEach((result) => {
      if (result.file) {
        const formDataUpload = new FormData()
        formDataUpload.append('file', result.file)
        formDataUpload.append('type', 'result')
        uploadPromises.push(
          apiClient.uploadFile(`/edital/edital/${edital.id}/upload/`, formDataUpload)
        )
      }
    })

    if (uploadPromises.length > 0) {
      await Promise.all(uploadPromises)
    }

    return edital
  },

  async updateEdital(id: string, formData: EditalFormData): Promise<EditalResponse> {
    const payload = this.formatPayload(formData)
    return apiClient.put(`/edital/edital/${id}/`, payload)
  },

  async getEditals(): Promise<EditalResponse[]> {
    return apiClient.get('/edital/edital/')
  },

  async getEdital(id: string): Promise<EditalResponse> {
    return apiClient.get(`/edital/edital/${id}/`)
  },
}
