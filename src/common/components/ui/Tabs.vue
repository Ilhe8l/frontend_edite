<template>
  <div class="w-full">
    <div class="border-b border-border">
      <nav class="-mb-px flex space-x-8" aria-label="Tabs">
        <button
          v-for="tab in tabs"
          :key="tab.value"
          type="button"
          :class="tabClasses(tab.value)"
          @click="selectTab(tab.value)"
        >
          {{ tab.label }}
        </button>
      </nav>
    </div>
    <div class="mt-4">
      <slot :name="modelValue" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface Tab {
  label: string
  value: string
}

export interface TabsProps {
  modelValue: string
  tabs: Tab[]
}

const props = defineProps<TabsProps>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const tabClasses = (value: string) => {
  const base = 'whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm transition-colors'
  const active = value === props.modelValue
  
  if (active) {
    return `${base} border-primary text-primary`
  }
  return `${base} border-transparent text-muted-foreground hover:text-foreground hover:border-border`
}

const selectTab = (value: string) => {
  emit('update:modelValue', value)
}
</script>
