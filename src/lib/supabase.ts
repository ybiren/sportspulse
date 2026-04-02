import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://YOUR_PROJECT.supabase.co'
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'YOUR_ANON_KEY'

export const supabase = createClient(supabaseUrl, supabaseKey)

export interface Match {
  id: string
  home_team: string
  away_team: string
  home_short: string
  away_short: string
  home_score: number
  away_score: number
  minute: number
  status: 'live' | 'upcoming' | 'finished'
  competition: string
  kickoff: string
  win_prob_home: number
}

export function subscribeToMatch(matchId: string, onUpdate: (match: Match) => void) {
  return supabase
    .channel(`match:${matchId}`)
    .on(
      'postgres_changes',
      { event: 'UPDATE', schema: 'public', table: 'matches', filter: `id=eq.${matchId}` },
      (payload) => onUpdate(payload.new as Match)
    )
    .subscribe()
}
