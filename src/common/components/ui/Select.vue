<template>
  <div class="w-full">
    <label v-if="label" :for="selectId" class="block text-sm font-medium mb-1.5">
      {{ label }}
    </label>
    <div class="relative">
      <select
        :id="selectId"
        :value="modelValue"
        :disabled="disabled"
        :class="selectClasses"
        @change="handleChange"
      >
        <option v-if="placeholder" value="" disabled>{{ placeholder }}</option>
        <option
          v-for="option in options"
          :key="getOptionValue(option)"
          :value="getOptionValue(option)"
        >
          {{ getOptionLabel(option) }}
        </option>
      </select>
      <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-muted-foreground">
        <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </div>
    </div>
    <p v-if="helperText" class="mt-1.5 text-sm text-muted-foreground">
      {{ helperText }}
    </p>
    <p v-if="error" class="mt-1.5 text-sm text-destructive">
      {{ error }}
    </p>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface SelectOption {
  label: string
  value: string | number
}

export interface SelectProps {
  modelValue?: string | number
  options: (SelectOption | string | number)[]
  label?: string
  placeholder?: string
  disabled?: boolean
  error?: string
  helperText?: string
  id?: string
}

const props = withDefaults(defineProps<SelectProps>(), {
  disabled: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
}>()

const selectId = computed(() => props.id || `select-${Math.random().toString(36).substr(2, 9)}`)

const selectClasses = computed(() => {
  const base = 'flex h-10 w-full appearance-none rounded-md border px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50'
  const errorClass = props.error ? 'border-destructive focus-visible:ring-destructive' : 'border-input bg-background'
  return `${base} ${errorClass}`
})

const getOptionValue = (option: SelectOption | string | number): string | number => {
  if (typeof option === 'object' && option !== null) {
    return option.value
  }
  return option
}

const getOptionLabel = (option: SelectOption | string | number): string => {
  if (typeof option === 'object' && option !== null) {
    return option.label
  }
  return String(option)
}

const handleChange = (event: Event) => {
  const target = event.target as HTMLSelectElement
  emit('update:modelValue', target.value)
}
</script>
