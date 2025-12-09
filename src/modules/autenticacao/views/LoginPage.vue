<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center px-4">
    <div class="max-w-md w-full">
      <Card>
        <CardHeader>
          <div class="flex justify-center mb-4">
            <Logo :width="160" :height="64" />
          </div>
          <CardTitle class="text-center">Gestão de Editais</CardTitle>
          <CardDescription class="text-center">
            Entre com suas credenciais para acessar o sistema
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form @submit.prevent="handleSubmit" class="space-y-4">
            <Input
              v-model="email"
              type="email"
              label="Email"
              placeholder="seu@email.com"
              :error="errors.email"
              :disabled="isLoading"
              @blur="validateEmail"
            />
            
            <Input
              v-model="password"
              type="password"
              label="Senha"
              placeholder="••••••••"
              :error="errors.password"
              :disabled="isLoading"
              @blur="validatePassword"
            />

            <Alert v-if="errorMessage" variant="destructive">
              {{ errorMessage }}
            </Alert>

            <Button
              type="submit"
              class="w-full"
              :loading="isLoading"
              :disabled="isLoading"
            >
              Entrar
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/common/store/auth'
import { useUiStore } from '@/common/store/ui'
import Card from '@/common/components/ui/Card.vue'
import CardHeader from '@/common/components/ui/CardHeader.vue'
import CardTitle from '@/common/components/ui/CardTitle.vue'
import CardDescription from '@/common/components/ui/CardDescription.vue'
import CardContent from '@/common/components/ui/CardContent.vue'
import Input from '@/common/components/ui/Input.vue'
import Button from '@/common/components/ui/Button.vue'
import Alert from '@/common/components/ui/Alert.vue'
import Logo from '@/common/components/ui/Logo.vue'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const uiStore = useUiStore()

const email = ref('')
const password = ref('')
const isLoading = ref(false)
const errorMessage = ref('')
const errors = ref({
  email: '',
  password: '',
})

const validateEmail = () => {
  if (!email.value) {
    errors.value.email = 'Email é obrigatório'
    return false
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
    errors.value.email = 'Email inválido'
    return false
  }
  errors.value.email = ''
  return true
}

const validatePassword = () => {
  if (!password.value) {
    errors.value.password = 'Senha é obrigatória'
    return false
  }
  if (password.value.length < 6) {
    errors.value.password = 'Senha deve ter no mínimo 6 caracteres'
    return false
  }
  errors.value.password = ''
  return true
}

const handleSubmit = async () => {
  // Validate all fields
  const isEmailValid = validateEmail()
  const isPasswordValid = validatePassword()
  
  if (!isEmailValid || !isPasswordValid) {
    return
  }

  isLoading.value = true
  errorMessage.value = ''

  try {
    await authStore.login({
      email: email.value,
      password: password.value,
    })

    uiStore.showToast({
      type: 'success',
      message: 'Login realizado com sucesso!',
    })

    // Redirect to intended page or home
    const redirect = route.query.redirect as string
    router.push(redirect || '/')
  } catch (error: any) {
    console.error('Login error:', error)
    errorMessage.value = error.response?.data?.message || 'Erro ao fazer login. Verifique suas credenciais.'
  } finally {
    isLoading.value = false
  }
}
</script>
