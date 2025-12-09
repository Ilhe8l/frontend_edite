<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b">
      <div class="container mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <Button variant="ghost" size="sm" @click="router.push('/')">
              ← Voltar
            </Button>
            <h1 class="text-2xl font-bold text-gray-900">Gestão de Editais</h1>
          </div>
          <div class="flex items-center space-x-4">
            <span class="text-sm text-gray-600">{{ authStore.user?.name }}</span>
            <Button variant="outline" size="sm" @click="handleLogout">
              Sair
            </Button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
      <div class="max-w-4xl mx-auto">
        <Card>
          <CardHeader>
            <CardTitle>Criar Novo Edital</CardTitle>
            <CardDescription>
              Preencha os campos abaixo para criar um novo edital
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form @submit.prevent="handleSubmit" class="space-y-6">
              <!-- Basic Fields -->
              <div class="space-y-4">
                <Input
                  v-model="formData.title"
                  label="Título *"
                  placeholder="Ex: Edital de Chamada Pública nº 001/2024"
                  :error="errors.title"
                  :disabled="isSubmitting"
                  @blur="validateField('title')"
                />

                <div>
                  <label class="block text-sm font-medium mb-1.5">Descrição *</label>
                  <textarea
                    v-model="formData.description"
                    rows="4"
                    class="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                    :class="errors.description ? 'border-destructive' : ''"
                    placeholder="Descreva o edital..."
                    :disabled="isSubmitting"
                    @blur="validateField('description')"
                  />
                  <p v-if="errors.description" class="mt-1.5 text-sm text-destructive">
                    {{ errors.description }}
                  </p>
                </div>

                <Select
                  v-model="formData.status"
                  label="Status *"
                  :options="statusOptions"
                  :error="errors.status"
                  :disabled="isSubmitting"
                />
              </div>

              <!-- Dynamic Fields -->
              <div class="border-t pt-6">
                <DynamicFieldsRepeater v-model="formData.dynamicFields" />
              </div>

              <!-- File Uploads -->
              <div class="border-t pt-6">
                <Tabs v-model="activeTab" :tabs="fileTabs">
                  <template #main>
                    <FileUploaderCard
                      title="PDF Principal"
                      description="Faça upload do documento principal do edital"
                      v-model="mainPDFArray"
                      :multiple="false"
                    />
                  </template>
                  <template #annexes>
                    <FileUploaderCard
                      title="Anexos"
                      description="Faça upload de documentos anexos"
                      v-model="formData.annexes"
                      :multiple="true"
                    />
                  </template>
                  <template #results>
                    <FileUploaderCard
                      title="Resultados"
                      description="Faça upload de documentos de resultados"
                      v-model="formData.results"
                      :multiple="true"
                    />
                  </template>
                </Tabs>
              </div>

              <!-- Error Alert -->
              <Alert v-if="submitError" variant="destructive">
                {{ submitError }}
              </Alert>

              <!-- Success Alert -->
              <Alert v-if="submitSuccess" variant="success">
                Edital criado com sucesso!
              </Alert>

              <!-- JSON Preview (Debug) -->
              <details v-if="showDebug" class="border rounded-lg p-4">
                <summary class="cursor-pointer font-medium text-sm">
                  Preview do Payload JSON
                </summary>
                <pre class="mt-2 text-xs bg-gray-50 p-3 rounded overflow-auto">{{ payloadPreview }}</pre>
              </details>

              <!-- Actions -->
              <div class="flex justify-end space-x-3">
                <Button
                  type="button"
                  variant="outline"
                  @click="router.push('/')"
                  :disabled="isSubmitting"
                >
                  Cancelar
                </Button>
                <Button
                  type="submit"
                  :loading="isSubmitting"
                  :disabled="isSubmitting"
                >
                  Criar Edital
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/common/store/auth'
import { useUiStore } from '@/common/store/ui'
import { editalService } from '@/modules/gestao-editais/services/edital.service'
import Card from '@/common/components/ui/Card.vue'
import CardHeader from '@/common/components/ui/CardHeader.vue'
import CardTitle from '@/common/components/ui/CardTitle.vue'
import CardDescription from '@/common/components/ui/CardDescription.vue'
import CardContent from '@/common/components/ui/CardContent.vue'
import Input from '@/common/components/ui/Input.vue'
import Select from '@/common/components/ui/Select.vue'
import Button from '@/common/components/ui/Button.vue'
import Alert from '@/common/components/ui/Alert.vue'
import Tabs from '@/common/components/ui/Tabs.vue'
import DynamicFieldsRepeater from '@/modules/gestao-editais/components/DynamicFieldsRepeater.vue'
import FileUploaderCard from '@/modules/gestao-editais/components/FileUploaderCard.vue'
import type { EditalFormData, DynamicField, UploadedFile } from '@/common/types/edital.types'

const router = useRouter()
const authStore = useAuthStore()
const uiStore = useUiStore()

const formData = ref<EditalFormData>({
  title: '',
  description: '',
  status: 'open',
  mainPDF: null,
  dynamicFields: [],
  annexes: [],
  results: [],
})

const mainPDFArray = ref<UploadedFile[]>([])
const activeTab = ref('main')
const isSubmitting = ref(false)
const submitError = ref('')
const submitSuccess = ref(false)
const showDebug = ref(true)

const errors = ref({
  title: '',
  description: '',
  status: '',
})

const statusOptions = [
  { label: 'Aberto', value: 'open' },
  { label: 'Fechado', value: 'closed' },
  { label: 'Em Análise', value: 'analyzing' },
]

const fileTabs = [
  { label: 'PDF Principal', value: 'main' },
  { label: 'Anexos', value: 'annexes' },
  { label: 'Resultados', value: 'results' },
]

// Sync mainPDF with array
watch(mainPDFArray, (newValue) => {
  formData.value.mainPDF = newValue.length > 0 ? newValue[0] : null
}, { deep: true })

const payloadPreview = computed(() => {
  return JSON.stringify(editalService.formatPayload(formData.value), null, 2)
})

const validateField = (field: keyof typeof errors.value) => {
  switch (field) {
    case 'title':
      if (!formData.value.title.trim()) {
        errors.value.title = 'Título é obrigatório'
      } else {
        errors.value.title = ''
      }
      break
    case 'description':
      if (!formData.value.description.trim()) {
        errors.value.description = 'Descrição é obrigatória'
      } else {
        errors.value.description = ''
      }
      break
    case 'status':
      if (!formData.value.status) {
        errors.value.status = 'Status é obrigatório'
      } else {
        errors.value.status = ''
      }
      break
  }
}

const validateForm = (): boolean => {
  validateField('title')
  validateField('description')
  validateField('status')

  return !errors.value.title && !errors.value.description && !errors.value.status
}

const handleSubmit = async () => {
  submitError.value = ''
  submitSuccess.value = false

  if (!validateForm()) {
    submitError.value = 'Por favor, corrija os erros no formulário'
    return
  }

  isSubmitting.value = true

  try {
    await editalService.createEdital(formData.value)
    
    submitSuccess.value = true
    uiStore.showToast({
      type: 'success',
      message: 'Edital criado com sucesso!',
    })

    // Reset form after 2 seconds
    setTimeout(() => {
      resetForm()
    }, 2000)
  } catch (error: any) {
    console.error('Error creating edital:', error)
    submitError.value = error.response?.data?.message || 'Erro ao criar edital. Tente novamente.'
    uiStore.showToast({
      type: 'error',
      message: 'Erro ao criar edital',
    })
  } finally {
    isSubmitting.value = false
  }
}

const resetForm = () => {
  formData.value = {
    title: '',
    description: '',
    status: 'open',
    mainPDF: null,
    dynamicFields: [],
    annexes: [],
    results: [],
  }
  mainPDFArray.value = []
  errors.value = {
    title: '',
    description: '',
    status: '',
  }
  submitSuccess.value = false
  submitError.value = ''
}

const handleLogout = () => {
  authStore.logout()
  uiStore.showToast({
    type: 'success',
    message: 'Logout realizado com sucesso',
  })
  router.push('/login')
}
</script>
