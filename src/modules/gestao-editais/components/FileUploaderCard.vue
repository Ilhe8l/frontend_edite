<template>
  <Card>
    <CardHeader>
      <CardTitle>{{ title }}</CardTitle>
      <CardDescription v-if="description">{{ description }}</CardDescription>
    </CardHeader>
    <CardContent>
      <!-- Upload Area -->
      <div
        class="border-2 border-dashed rounded-lg p-8 text-center transition-colors"
        :class="dragActive ? 'border-primary bg-primary/5' : 'border-gray-300'"
        @dragover.prevent="handleDragOver"
        @dragleave.prevent="handleDragLeave"
        @drop.prevent="handleDrop"
      >
        <input
          ref="fileInputRef"
          type="file"
          accept="application/pdf"
          :multiple="multiple"
          class="hidden"
          @change="handleFileSelect"
        />
        
        <div class="flex flex-col items-center space-y-2">
          <div class="p-3 bg-gray-100 rounded-full">
            <svg class="h-8 w-8 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
            </svg>
          </div>
          <div>
            <p class="text-sm text-gray-600">
              Arraste arquivos PDF aqui ou
              <button
                type="button"
                class="text-primary hover:underline font-medium"
                @click="triggerFileInput"
              >
                clique para selecionar
              </button>
            </p>
            <p class="text-xs text-gray-500 mt-1">
              Apenas arquivos PDF são aceitos
            </p>
          </div>
        </div>
      </div>

      <!-- Error Message -->
      <Alert v-if="errorMessage" variant="destructive" class="mt-4">
        {{ errorMessage }}
      </Alert>

      <!-- Uploaded Files List -->
      <div v-if="uploadedFiles.length > 0" class="mt-6 space-y-3">
        <h4 class="text-sm font-semibold text-gray-900">Arquivos Carregados</h4>
        <div
          v-for="file in uploadedFiles"
          :key="file.id"
          class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
        >
          <div class="flex items-center space-x-3 flex-1 min-w-0">
            <div class="flex-shrink-0">
              <svg class="h-8 w-8 text-red-600" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="flex-1 min-w-0">
              <Input
                v-model="file.displayName"
                placeholder="Nome de exibição"
                class="text-sm"
                @blur="updateFile(file)"
              />
              <p class="text-xs text-gray-500 mt-1">
                {{ file.name }} • {{ formatFileSize(file.size) }}
              </p>
            </div>
          </div>
          <Button
            variant="ghost"
            size="sm"
            @click="removeFile(file.id)"
            class="ml-2"
          >
            <svg class="h-5 w-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </Button>
        </div>
      </div>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import Card from '@/common/components/ui/Card.vue'
import CardHeader from '@/common/components/ui/CardHeader.vue'
import CardTitle from '@/common/components/ui/CardTitle.vue'
import CardDescription from '@/common/components/ui/CardDescription.vue'
import CardContent from '@/common/components/ui/CardContent.vue'
import Input from '@/common/components/ui/Input.vue'
import Button from '@/common/components/ui/Button.vue'
import Alert from '@/common/components/ui/Alert.vue'
import type { UploadedFile } from '@/common/types/edital.types'

export interface FileUploaderCardProps {
  title: string
  description?: string
  modelValue: UploadedFile[]
  multiple?: boolean
}

const props = withDefaults(defineProps<FileUploaderCardProps>(), {
  multiple: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: UploadedFile[]]
}>()

const fileInputRef = ref<HTMLInputElement | null>(null)
const dragActive = ref(false)
const errorMessage = ref('')
const uploadedFiles = ref<UploadedFile[]>([...props.modelValue])

// Watch for external changes
watch(() => props.modelValue, (newValue) => {
  uploadedFiles.value = [...newValue]
}, { deep: true })

// Emit changes
watch(uploadedFiles, (newFiles) => {
  emit('update:modelValue', newFiles)
}, { deep: true })

const triggerFileInput = () => {
  fileInputRef.value?.click()
}

const handleDragOver = () => {
  dragActive.value = true
}

const handleDragLeave = () => {
  dragActive.value = false
}

const handleDrop = (event: DragEvent) => {
  dragActive.value = false
  const files = event.dataTransfer?.files
  if (files) {
    processFiles(Array.from(files))
  }
}

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  const files = target.files
  if (files) {
    processFiles(Array.from(files))
  }
  // Reset input
  if (fileInputRef.value) {
    fileInputRef.value.value = ''
  }
}

const processFiles = (files: File[]) => {
  errorMessage.value = ''

  // Validate file types
  const invalidFiles = files.filter(f => f.type !== 'application/pdf')
  if (invalidFiles.length > 0) {
    errorMessage.value = 'Apenas arquivos PDF são aceitos'
    return
  }

  // Check if multiple is allowed
  if (!props.multiple && files.length > 1) {
    errorMessage.value = 'Apenas um arquivo é permitido'
    return
  }

  // If not multiple, replace existing file
  if (!props.multiple) {
    uploadedFiles.value = []
  }

  // Add files
  files.forEach(file => {
    const uploadedFile: UploadedFile = {
      id: `file-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      name: file.name,
      displayName: file.name.replace('.pdf', ''),
      file: file,
      size: file.size,
      uploadedAt: new Date().toISOString(),
    }
    uploadedFiles.value.push(uploadedFile)
  })
}

const removeFile = (id: string) => {
  uploadedFiles.value = uploadedFiles.value.filter(f => f.id !== id)
}

const updateFile = (file: UploadedFile) => {
  const index = uploadedFiles.value.findIndex(f => f.id === file.id)
  if (index !== -1) {
    uploadedFiles.value[index] = { ...file }
  }
}

const formatFileSize = (bytes?: number): string => {
  if (!bytes) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`
}
</script>
