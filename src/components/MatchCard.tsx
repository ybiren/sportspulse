'use client'
import { Match } from '@/lib/supabase'

interface Props {
  match: Match
  onSelect: (match: Match) => void
}

export default function MatchCard({ match, onSelect }: Props) {
  const isLive = match.status === 'live'

  return (
    <div
      onClick={() => onSelect(match)}
      className="relative cursor-pointer rounded-2xl border border-white/10 bg-[#0E1420] p-5 transition hover:border-white/20 hover:bg-[#141B2A] overflow-hidden"
    >
      {/* Left accent bar */}
      <div
        className="absolute left-0 top-0 h-full w-[3px] rounded-l-2xl"
        style={{ background: isLive ? '#00E676' : '#FFAB00' }}
      />

      {/* Header */}
      <div className="mb-4 flex items-center justify-between">
        <span className="font-mono text-[10px] uppercase tracking-widest text-[#3D4F70]">
          {match.competition}
        </span>
        {isLive ? (
          <div className="flex items-center gap-1.5 rounded-full border border-[#00E676] bg-[rgba(0,230,118,0.12)] px-2.5 py-1">
            <div className="live-dot" />
            <span className="font-mono text-[10px] uppercase tracking-wider text-[#00E676]">Live</span>
          </div>
        ) : (
          <span className="rounded-full border border-[#FFAB00] bg-[rgba(255,171,0,0.12)] px-2.5 py-1 font-mono text-[10px] uppercase tracking-wider text-[#FFAB00]">
            {new Date(match.kickoff).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </span>
        )}
      </div>

      {/* Teams + Score */}
      <div className="flex items-center justify-between gap-4">
        <div className="flex-1 text-center">
          <div className="mx-auto mb-1.5 flex h-11 w-11 items-center justify-center rounded-full border border-white/10 bg-[#141B2A] font-bold text-sm">
            {match.home_short}
          </div>
          <div className="text-sm font-semibold">{match.home_team}</div>
        </div>

        <div className="shrink-0 text-center">
          {isLive ? (
            <>
              <div className="font-mono text-3xl font-bold">
                {match.home_score}
                <span className="text-[#3D4F70]"> – </span>
                {match.away_score}
              </div>
              <div className="mt-1 font-mono text-[10px] text-[#00E676]">{match.minute}&apos;</div>
            </>
          ) : (
            <div className="font-mono text-lg text-[#3D4F70]">vs</div>
          )}
        </div>

        <div className="flex-1 text-center">
          <div className="mx-auto mb-1.5 flex h-11 w-11 items-center justify-center rounded-full border border-white/10 bg-[#141B2A] font-bold text-sm">
            {match.away_short}
          </div>
          <div className="text-sm font-semibold">{match.away_team}</div>
        </div>
      </div>

      {/* AI Win Probability Bar */}
      {isLive && (
        <div className="mt-4 pt-4 border-t border-white/10">
          <div className="mb-1 flex justify-between font-mono text-[10px] text-[#3D4F70]">
            <span>AI Win Prob</span>
            <span>
              {Math.round(match.win_prob_home * 100)}% – {Math.round((1 - match.win_prob_home) * 100)}%
            </span>
          </div>
          <div className="h-1.5 w-full overflow-hidden rounded-full bg-white/10">
            <div
              className="h-full rounded-full bg-[#00E676] transition-all duration-1000"
              style={{ width: `${Math.round(match.win_prob_home * 100)}%` }}
            />
          </div>
        </div>
      )}
    </div>
  )
}
