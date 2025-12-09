<template>
  <div :class="cardClasses">
    <slot />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface CardProps {
  hover?: boolean
}

const props = withDefaults(defineProps<CardProps>(), {
  hover: false,
})

const cardClasses = computed(() => {
  const base = 'rounded-lg border bg-card text-card-foreground shadow-sm'
  const hoverClass = props.hover ? 'transition-shadow hover:shadow-md' : ''
  return `${base} ${hoverClass}`
})
</script>
