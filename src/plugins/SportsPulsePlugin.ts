import { registerPlugin } from '@capacitor/core'

export interface SportsPulsePlugin {
  startLiveActivity(options: {
    matchId: string
    homeTeam: string
    awayTeam: string
    homeTeamShort: string
    awayTeamShort: string
    competition: string
  }): Promise<{ status: string }>

  updateLiveActivity(options: {
    homeScore: number
    awayScore: number
    minute: number
    isHalfTime?: boolean
    lastEvent?: string
    winProbabilityHome: number
  }): Promise<{ status: string }>

  endLiveActivity(options: {
    finalHomeScore: number
    finalAwayScore: number
  }): Promise<{ status: string }>

  getPushToken(): Promise<{ token: string }>
  requestNotificationPermission(): Promise<{ granted: boolean }>
}

class SportsPulseWeb {
  async startLiveActivity()  { console.log('[SportsPulse] web noop'); return { status: 'noop' } }
  async updateLiveActivity() { return { status: 'noop' } }
  async endLiveActivity()    { return { status: 'noop' } }
  async getPushToken()       { return { token: 'web-mock-token' } }
  async requestNotificationPermission() { return { granted: true } }
}

export const SportsPulse = registerPlugin<SportsPulsePlugin>('SportsPulse', {
  web: () => new SportsPulseWeb() as any,
})
