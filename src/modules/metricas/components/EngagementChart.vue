<template>
  <Card>
    <CardHeader>
      <CardTitle>Engajamento por Edital</CardTitle>
      <CardDescription>
        Clique em uma barra para filtrar mensagens por edital
      </CardDescription>
    </CardHeader>
    <CardContent>
      <div class="space-y-6">
        <!-- Bar Chart -->
        <div class="h-80">
          <canvas ref="barChartRef"></canvas>
        </div>

        <!-- Pie Chart -->
        <div class="h-64">
          <canvas ref="pieChartRef"></canvas>
        </div>
      </div>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, onBeforeUnmount } from 'vue'
import {
  Chart,
  BarController,
  PieController,
  CategoryScale,
  LinearScale,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js'
import Card from '@/common/components/ui/Card.vue'
import CardHeader from '@/common/components/ui/CardHeader.vue'
import CardTitle from '@/common/components/ui/CardTitle.vue'
import CardDescription from '@/common/components/ui/CardDescription.vue'
import CardContent from '@/common/components/ui/CardContent.vue'
import type { EditalMetrics } from '@/common/types/api.types'

// Register Chart.js components
Chart.register(
  BarController,
  PieController,
  CategoryScale,
  LinearScale,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend
)

export interface EngagementChartProps {
  data: EditalMetrics[]
}

const props = defineProps<EngagementChartProps>()

const emit = defineEmits<{
  'edital-click': [id: string]
}>()

const barChartRef = ref<HTMLCanvasElement | null>(null)
const pieChartRef = ref<HTMLCanvasElement | null>(null)
let barChart: Chart | null = null
let pieChart: Chart | null = null

const colors = [
  'rgba(59, 130, 246, 0.8)',   // blue
  'rgba(16, 185, 129, 0.8)',   // green
  'rgba(139, 92, 246, 0.8)',   // purple
  'rgba(251, 146, 60, 0.8)',   // orange
  'rgba(236, 72, 153, 0.8)',   // pink
]

const createBarChart = () => {
  if (!barChartRef.value || !props.data.length) return

  const ctx = barChartRef.value.getContext('2d')
  if (!ctx) return

  // Destroy existing chart
  if (barChart) {
    barChart.destroy()
  }

  barChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: props.data.map(d => d.title.substring(0, 30) + '...'),
      datasets: [
        {
          label: 'Mensagens',
          data: props.data.map(d => d.messageCount),
          backgroundColor: colors,
          borderColor: colors.map(c => c.replace('0.8', '1')),
          borderWidth: 1,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      onClick: (event, elements) => {
        if (elements.length > 0) {
          const index = elements[0].index
          emit('edital-click', props.data[index].id)
        }
      },
      plugins: {
        legend: {
          display: false,
        },
        tooltip: {
          callbacks: {
            label: (context) => {
              const edital = props.data[context.dataIndex]
              return [
                `Mensagens: ${edital.messageCount}`,
                `Usuários: ${edital.uniqueUsers}`,
                `Última mensagem: ${edital.lastMessage}`,
              ]
            },
          },
        },
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            precision: 0,
          },
        },
      },
    },
  })
}

const createPieChart = () => {
  if (!pieChartRef.value || !props.data.length) return

  const ctx = pieChartRef.value.getContext('2d')
  if (!ctx) return

  // Destroy existing chart
  if (pieChart) {
    pieChart.destroy()
  }

  pieChart = new Chart(ctx, {
    type: 'pie',
    data: {
      labels: props.data.map(d => d.title.substring(0, 20) + '...'),
      datasets: [
        {
          data: props.data.map(d => d.messageCount),
          backgroundColor: colors,
          borderColor: '#fff',
          borderWidth: 2,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      onClick: (event, elements) => {
        if (elements.length > 0) {
          const index = elements[0].index
          emit('edital-click', props.data[index].id)
        }
      },
      plugins: {
        legend: {
          position: 'bottom',
        },
        tooltip: {
          callbacks: {
            label: (context) => {
              const edital = props.data[context.dataIndex]
              const total = props.data.reduce((sum, d) => sum + d.messageCount, 0)
              const percentage = ((edital.messageCount / total) * 100).toFixed(1)
              return `${edital.messageCount} mensagens (${percentage}%)`
            },
          },
        },
      },
    },
  })
}

onMounted(() => {
  createBarChart()
  createPieChart()
})

watch(() => props.data, () => {
  createBarChart()
  createPieChart()
}, { deep: true })

onBeforeUnmount(() => {
  if (barChart) {
    barChart.destroy()
  }
  if (pieChart) {
    pieChart.destroy()
  }
})
</script>
