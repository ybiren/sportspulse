'use client'
import { useEffect, useState } from 'react'
import { subscribeToMatch, Match } from '@/lib/supabase'
import { SportsPulse } from '@/plugins/SportsPulsePlugin'
import MatchCard from '@/components/MatchCard'

const MOCK_MATCHES: Match[] = [
  {
    id: '1',
    home_team: 'Man United', away_team: 'Chelsea',
    home_short: 'MU', away_short: 'CHE',
    home_score: 2, away_score: 1, minute: 67,
    status: 'live', competition: 'Premier League · GW32',
    kickoff: new Date().toISOString(),
    win_prob_home: 0.72,
  },
  {
    id: '2',
    home_team: 'Barcelona', away_team: 'Atlético',
    home_short: 'BAR', away_short: 'ATM',
    home_score: 3, away_score: 3, minute: 88,
    status: 'live', competition: 'La Liga · GW30',
    kickoff: new Date().toISOString(),
    win_prob_home: 0.41,
  },
  {
    id: '3',
    home_team: 'Liverpool', away_team: 'Bayern',
    home_short: 'LIV', away_short: 'BYN',
    home_score: 0, away_score: 0, minute: 0,
    status: 'upcoming', competition: 'Champions League · SF',
    kickoff: new Date(Date.now() + 3 * 60 * 60 * 1000).toISOString(),
    win_prob_home: 0.48,
  },
]

export default function HomePage() {
  const [matches, setMatches]     = useState<Match[]>(MOCK_MATCHES)
  const [activeTab, setActiveTab] = useState<'live' | 'upcoming'>('live')
  const [pushReady, setPushReady] = useState(false)

  // Request push permissions on mount
  useEffect(() => {
    SportsPulse.requestNotificationPermission()
      .then(({ granted }) => setPushReady(granted))
      .catch(() => {})
  }, [])

  // Supabase Realtime subscriptions for live matches
  useEffect(() => {
    const channels = matches
      .filter(m => m.status === 'live')
      .map(m =>
        subscribeToMatch(m.id, (updated) => {
          setMatches(prev => prev.map(x => x.id === updated.id ? updated : x))
          SportsPulse.updateLiveActivity({
            homeScore: updated.home_score,
            awayScore: updated.away_score,
            minute: updated.minute,
            winProbabilityHome: updated.win_prob_home,
          }).catch(() => {})
        })
      )
    return () => { channels.forEach(ch => ch.unsubscribe()) }
  }, [])

  const handleSelectMatch = async (match: Match) => {
    if (match.status === 'live') {
      await SportsPulse.startLiveActivity({
        matchId: match.id,
        homeTeam: match.home_team,
        awayTeam: match.away_team,
        homeTeamShort: match.home_short,
        awayTeamShort: match.away_short,
        competition: match.competition,
      }).catch(() => {})
    }
  }

  const liveMatches     = matches.filter(m => m.status === 'live')
  const upcomingMatches = matches.filter(m => m.status === 'upcoming')
  const displayed       = activeTab === 'live' ? liveMatches : upcomingMatches

  return (
    <main className="min-h-screen bg-[#080C14] text-[#F0F4FF]">

      {/* Nav */}
      <nav className="sticky top-0 z-50 flex items-center justify-between border-b border-white/10 bg-[rgba(8,12,20,0.85)] px-5 py-4 backdrop-blur-xl">
        <div className="text-2xl" style={{ fontFamily: "'DM Serif Display', serif" }}>
          Sport<span className="text-[#00E676]">Pulse</span>
        </div>
        {pushReady && (
          <div className="flex items-center gap-1.5 rounded-full bg-[rgba(0,230,118,0.1)] px-2.5 py-1">
            <div className="live-dot" />
            <span className="font-mono text-[10px] text-[#00E676]">Push On</span>
          </div>
        )}
      </nav>

      <div className="mx-auto max-w-2xl px-4 py-6">

        {/* Header */}
        <div className="mb-6">
          <h1 className="text-4xl leading-tight" style={{ fontFamily: "'DM Serif Display', serif" }}>
            Live <em className="italic text-[#00E676]">Matches</em>
          </h1>
          <p className="mt-1 text-sm text-[#7B8DB0]">
            Real-time scores · AI predictions · Tap to track
          </p>
        </div>

        {/* Tabs */}
        <div className="mb-5 flex gap-2">
          {(['live', 'upcoming'] as const).map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`flex items-center gap-2 rounded-full border px-4 py-1.5 font-mono text-xs uppercase tracking-wider transition ${
                activeTab === tab
                  ? 'border-[#00E676] bg-[rgba(0,230,118,0.12)] text-[#00E676]'
                  : 'border-white/10 text-[#3D4F70] hover:border-white/20'
              }`}
            >
              {tab === 'live' && <div className="live-dot" />}
              {tab} ({tab === 'live' ? liveMatches.length : upcomingMatches.length})
            </button>
          ))}
        </div>

        {/* Match list */}
        <div className="flex flex-col gap-4">
          {displayed.map(match => (
            <MatchCard key={match.id} match={match} onSelect={handleSelectMatch} />
          ))}
        </div>

        <p className="mt-8 text-center font-mono text-[10px] text-[#3D4F70]">
          Tap a live match to start iOS Live Activity · Powered by Supabase Realtime
        </p>
      </div>
    </main>
  )
}
