<template>
  <span :class="badgeClasses">
    <slot />
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface BadgeProps {
  variant?: 'default' | 'secondary' | 'destructive' | 'success' | 'outline'
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<BadgeProps>(), {
  variant: 'default',
  size: 'md',
})

const badgeClasses = computed(() => {
  const base = 'inline-flex items-center rounded-full font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2'
  
  const variants = {
    default: 'bg-primary text-primary-foreground hover:bg-primary/80',
    secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
    destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/80',
    success: 'bg-green-500 text-white hover:bg-green-600',
    outline: 'border border-input bg-background hover:bg-accent hover:text-accent-foreground',
  }
  
  const sizes = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-2.5 py-0.5 text-sm',
    lg: 'px-3 py-1 text-base',
  }
  
  return `${base} ${variants[props.variant]} ${sizes[props.size]}`
})
</script>
