<template>
  <div class="w-full">
    <label v-if="label" :for="inputId" class="block text-sm font-medium mb-1.5">
      {{ label }}
    </label>
    <input
      :id="inputId"
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      :class="inputClasses"
      @input="handleInput"
      @blur="emit('blur', $event)"
      @focus="emit('focus', $event)"
    />
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

export interface InputProps {
  modelValue?: string | number
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url'
  label?: string
  placeholder?: string
  disabled?: boolean
  error?: string
  helperText?: string
  id?: string
}

const props = withDefaults(defineProps<InputProps>(), {
  type: 'text',
  disabled: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
  blur: [event: FocusEvent]
  focus: [event: FocusEvent]
}>()

const inputId = computed(() => props.id || `input-${Math.random().toString(36).substr(2, 9)}`)

const inputClasses = computed(() => {
  const base = 'flex h-10 w-full rounded-md border px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50'
  const errorClass = props.error ? 'border-destructive focus-visible:ring-destructive' : 'border-input bg-background'
  return `${base} ${errorClass}`
})

const handleInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  const value = props.type === 'number' ? Number(target.value) : target.value
  emit('update:modelValue', value)
}
</script>
