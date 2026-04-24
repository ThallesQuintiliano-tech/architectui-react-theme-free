export type ApiHealth = {
  ok: boolean
  service: string
  time: string
}

export async function getHealth(): Promise<ApiHealth> {
  const res = await fetch('/api/health', {
    headers: { Accept: 'application/json' },
  })

  if (!res.ok) {
    throw new Error(`Health request failed (${res.status})`)
  }

  return (await res.json()) as ApiHealth
}

