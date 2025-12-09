<template>
  <div class="space-y-4">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900">Campos Dinâmicos</h3>
      <Button @click="addField" size="sm">
        Adicionar Campo
      </Button>
    </div>

    <div v-if="fields.length === 0" class="text-center py-8 text-gray-500">
      Nenhum campo adicionado. Clique em "Adicionar Campo" para começar.
    </div>

    <div v-else class="space-y-3">
      <Card v-for="field in fields" :key="field.id" class="p-4">
        <div class="flex gap-3 items-start">
          <div class="flex-1">
            <Input
              v-model="field.key"
              placeholder="Chave (ex: prazo)"
              label="Chave"
              :error="getFieldError(field.id, 'key')"
              @blur="validateField(field.id)"
            />
          </div>
          <div class="flex-1">
            <Input
              v-model="field.value"
              placeholder="Valor (ex: 31/01/2024)"
              label="Valor"
              :error="getFieldError(field.id, 'value')"
              @blur="validateField(field.id)"
            />
          </div>
          <div class="pt-6">
            <Button
              variant="destructive"
              size="sm"
              @click="removeField(field.id)"
              :disabled="fields.length === 1"
            >
              Remover
            </Button>
          </div>
        </div>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import Card from '@/common/components/ui/Card.vue'
import Input from '@/common/components/ui/Input.vue'
import Button from '@/common/components/ui/Button.vue'
import type { DynamicField } from '@/common/types/edital.types'

export interface DynamicFieldsRepeaterProps {
  modelValue: DynamicField[]
}

const props = defineProps<DynamicFieldsRepeaterProps>()

const emit = defineEmits<{
  'update:modelValue': [value: DynamicField[]]
}>()

const fields = ref<DynamicField[]>([...props.modelValue])
const fieldErrors = ref<Record<string, { key?: string; value?: string }>>({})

// Watch for external changes
watch(() => props.modelValue, (newValue) => {
  fields.value = [...newValue]
}, { deep: true })

// Emit changes
watch(fields, (newFields) => {
  emit('update:modelValue', newFields)
}, { deep: true })

const addField = () => {
  const newField: DynamicField = {
    id: `field-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
    key: '',
    value: '',
  }
  fields.value.push(newField)
}

const removeField = (id: string) => {
  fields.value = fields.value.filter(f => f.id !== id)
  delete fieldErrors.value[id]
}

const validateField = (id: string) => {
  const field = fields.value.find(f => f.id === id)
  if (!field) return

  const errors: { key?: string; value?: string } = {}

  // Check for duplicate keys
  const duplicateKey = fields.value.find(
    f => f.id !== id && f.key && f.key === field.key
  )
  if (duplicateKey) {
    errors.key = 'Chave duplicada'
  }

  // Check if key is empty but value is filled
  if (!field.key && field.value) {
    errors.key = 'Chave é obrigatória quando valor está preenchido'
  }

  // Check if value is empty but key is filled
  if (field.key && !field.value) {
    errors.value = 'Valor é obrigatório quando chave está preenchida'
  }

  if (Object.keys(errors).length > 0) {
    fieldErrors.value[id] = errors
  } else {
    delete fieldErrors.value[id]
  }
}

const getFieldError = (id: string, type: 'key' | 'value'): string => {
  return fieldErrors.value[id]?.[type] || ''
}
</script>
