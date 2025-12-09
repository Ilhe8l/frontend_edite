<template>
  <svg 
    :width="width" 
    :height="height" 
    viewBox="0 0 200 80" 
    xmlns="http://www.w3.org/2000/svg"
    :class="className"
  >
    <rect width="200" height="80" :fill="bgColor" rx="8"/>
    <text 
      x="100" 
      y="50" 
      font-family="Arial, sans-serif" 
      font-size="32" 
      font-weight="bold" 
      :fill="textColor" 
      text-anchor="middle"
    >
      FAPES
    </text>
  </svg>
</template>

<script setup lang="ts">
export interface LogoProps {
  width?: number
  height?: number
  bgColor?: string
  textColor?: string
  class?: string
}

const props = withDefaults(defineProps<LogoProps>(), {
  width: 200,
  height: 80,
  bgColor: '#0284c7',
  textColor: 'white',
  class: '',
})

const className = props.class
</script>
