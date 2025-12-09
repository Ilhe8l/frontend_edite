<template>
  <div :class="alertClasses" role="alert">
    <div class="flex items-start">
      <div v-if="!hideIcon" class="flex-shrink-0">
        <component :is="iconComponent" class="h-5 w-5" />
      </div>
      <div :class="hideIcon ? '' : 'ml-3'" class="flex-1">
        <slot />
      </div>
      <button
        v-if="dismissible"
        type="button"
        class="ml-3 flex-shrink-0 inline-flex rounded-md p-1.5 focus:outline-none focus:ring-2 focus:ring-offset-2"
        @click="emit('dismiss')"
      >
        <span class="sr-only">Dismiss</span>
        <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
        </svg>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, h } from 'vue'

export interface AlertProps {
  variant?: 'default' | 'destructive' | 'success' | 'warning'
  dismissible?: boolean
  hideIcon?: boolean
}

const props = withDefaults(defineProps<AlertProps>(), {
  variant: 'default',
  dismissible: false,
  hideIcon: false,
})

const emit = defineEmits<{
  dismiss: []
}>()

const alertClasses = computed(() => {
  const base = 'relative w-full rounded-lg border p-4'
  
  const variants = {
    default: 'bg-background text-foreground border-border',
    destructive: 'bg-destructive/10 text-destructive border-destructive/50',
    success: 'bg-green-50 text-green-800 border-green-200',
    warning: 'bg-yellow-50 text-yellow-800 border-yellow-200',
  }
  
  return `${base} ${variants[props.variant]}`
})

const iconComponent = computed(() => {
  const icons = {
    default: () => h('svg', {
      fill: 'none',
      stroke: 'currentColor',
      viewBox: '0 0 24 24',
    }, [
      h('path', {
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
        'stroke-width': '2',
        d: 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z',
      }),
    ]),
    destructive: () => h('svg', {
      fill: 'none',
      stroke: 'currentColor',
      viewBox: '0 0 24 24',
    }, [
      h('path', {
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
        'stroke-width': '2',
        d: 'M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z',
      }),
    ]),
    success: () => h('svg', {
      fill: 'none',
      stroke: 'currentColor',
      viewBox: '0 0 24 24',
    }, [
      h('path', {
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
        'stroke-width': '2',
        d: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
      }),
    ]),
    warning: () => h('svg', {
      fill: 'none',
      stroke: 'currentColor',
      viewBox: '0 0 24 24',
    }, [
      h('path', {
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
        'stroke-width': '2',
        d: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z',
      }),
    ]),
  }
  
  return icons[props.variant]
})
</script>
