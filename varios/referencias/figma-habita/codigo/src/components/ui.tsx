import { ReactNode } from "react";

// ─── Buttons ─────────────────────────────────────────────────────────────────

interface BtnProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "ghost" | "danger" | "outline";
  size?: "sm" | "md" | "lg";
  children: ReactNode;
}

export function Btn({ variant = "primary", size = "md", className = "", children, ...rest }: BtnProps) {
  const base = "inline-flex items-center justify-center gap-2 font-medium rounded-lg transition-all duration-150 cursor-pointer border focus-visible:outline-2 focus-visible:outline-offset-2 disabled:opacity-50 disabled:cursor-not-allowed";
  const variants = {
    primary: "bg-[#C96E4B] text-[#F7F2E8] border-[#C96E4B] hover:bg-[#b8603f] active:bg-[#a5563a] focus-visible:outline-[#C96E4B]",
    secondary: "bg-[#243B32] text-[#F7F2E8] border-[#243B32] hover:bg-[#2f4d42] focus-visible:outline-[#243B32]",
    ghost: "bg-transparent text-[#243B32] border-transparent hover:bg-[#E8D8C4]/60",
    danger: "bg-red-600 text-white border-red-600 hover:bg-red-700",
    outline: "bg-transparent text-[#C96E4B] border-[#C96E4B] hover:bg-[#C96E4B]/8",
  };
  const sizes = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-5 py-2.5 text-sm",
    lg: "px-7 py-3.5 text-base",
  };
  return (
    <button className={`${base} ${variants[variant]} ${sizes[size]} ${className}`} {...rest}>
      {children}
    </button>
  );
}

// ─── Inputs ──────────────────────────────────────────────────────────────────

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  hint?: string;
  icon?: ReactNode;
}

export function Input({ label, error, hint, icon, className = "", ...rest }: InputProps) {
  return (
    <div className="flex flex-col gap-1.5">
      {label && <label className="text-sm font-medium text-[#252525]">{label}</label>}
      <div className="relative">
        {icon && <span className="absolute left-3 top-1/2 -translate-y-1/2 text-[#6b7280]">{icon}</span>}
        <input
          className={`w-full rounded-lg border border-[#ddd6c8] bg-white px-4 py-2.5 text-sm text-[#252525] placeholder-[#a39b8c] transition-colors focus:border-[#C96E4B] focus:outline-none ${icon ? "pl-10" : ""} ${error ? "border-red-400" : ""} ${className}`}
          {...rest}
        />
      </div>
      {error && <span className="text-xs text-red-500">{error}</span>}
      {hint && !error && <span className="text-xs text-[#6b7280]">{hint}</span>}
    </div>
  );
}

interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  children: ReactNode;
}

export function Select({ label, className = "", children, ...rest }: SelectProps) {
  return (
    <div className="flex flex-col gap-1.5">
      {label && <label className="text-sm font-medium text-[#252525]">{label}</label>}
      <select
        className={`w-full rounded-lg border border-[#ddd6c8] bg-white px-4 py-2.5 text-sm text-[#252525] focus:border-[#C96E4B] focus:outline-none appearance-none cursor-pointer ${className}`}
        {...rest}
      >
        {children}
      </select>
    </div>
  );
}

// ─── Badges / Tags ────────────────────────────────────────────────────────────

interface BadgeProps { label: string; variant?: "venta" | "arriendo" | "success" | "warning" | "info" | "neutral" | "danger"; }

export function Badge({ label, variant = "neutral" }: BadgeProps) {
  const styles = {
    venta: "bg-[#C96E4B]/15 text-[#9b5038] border-[#C96E4B]/30",
    arriendo: "bg-[#243B32]/12 text-[#243B32] border-[#243B32]/25",
    success: "bg-[#83946A]/15 text-[#5a6a49] border-[#83946A]/30",
    warning: "bg-amber-100 text-amber-700 border-amber-200",
    info: "bg-sky-100 text-sky-700 border-sky-200",
    neutral: "bg-[#E8D8C4] text-[#5a5244] border-[#ddd6c8]",
    danger: "bg-red-100 text-red-700 border-red-200",
  };
  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${styles[variant]}`}>
      {label}
    </span>
  );
}

// ─── Cards ───────────────────────────────────────────────────────────────────

export function Card({ children, className = "", onClick }: { children: ReactNode; className?: string; onClick?: () => void }) {
  return (
    <div className={`bg-[#F7F2E8] border border-[#ddd6c8] rounded-2xl shadow-sm ${className}`} onClick={onClick}>
      {children}
    </div>
  );
}

export function SandCard({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div className={`bg-[#E8D8C4] border border-[#d6c4ab] rounded-2xl ${className}`}>
      {children}
    </div>
  );
}

// ─── Section title ────────────────────────────────────────────────────────────

export function SectionTitle({ title, subtitle }: { title: string; subtitle?: string }) {
  return (
    <div className="mb-8">
      <h2 className="font-display text-3xl font-semibold text-[#243B32] leading-tight">{title}</h2>
      {subtitle && <p className="mt-2 text-[#6b7280] text-base">{subtitle}</p>}
    </div>
  );
}

// ─── Toast / Alert ────────────────────────────────────────────────────────────

export function Alert({ type, message }: { type: "success" | "error" | "info"; message: string }) {
  const styles = {
    success: "bg-[#83946A]/15 border-[#83946A]/40 text-[#3d5230]",
    error: "bg-red-50 border-red-200 text-red-700",
    info: "bg-[#243B32]/10 border-[#243B32]/25 text-[#243B32]",
  };
  const icons = { success: "✓", error: "✕", info: "ℹ" };
  return (
    <div className={`flex items-start gap-3 rounded-xl border p-4 text-sm ${styles[type]}`}>
      <span className="font-bold text-base leading-none mt-0.5">{icons[type]}</span>
      <span>{message}</span>
    </div>
  );
}

// ─── Pagination ───────────────────────────────────────────────────────────────

export function Pagination({ current, total, onChange }: { current: number; total: number; onChange: (p: number) => void }) {
  return (
    <div className="flex items-center gap-1.5">
      <button
        onClick={() => onChange(Math.max(1, current - 1))}
        disabled={current === 1}
        className="w-9 h-9 rounded-lg border border-[#ddd6c8] text-sm flex items-center justify-center disabled:opacity-40 hover:bg-[#E8D8C4] transition-colors"
      >
        ‹
      </button>
      {Array.from({ length: total }, (_, i) => i + 1).map(p => (
        <button
          key={p}
          onClick={() => onChange(p)}
          className={`w-9 h-9 rounded-lg text-sm font-medium transition-colors ${p === current ? "bg-[#243B32] text-[#F7F2E8]" : "border border-[#ddd6c8] hover:bg-[#E8D8C4]"}`}
        >
          {p}
        </button>
      ))}
      <button
        onClick={() => onChange(Math.min(total, current + 1))}
        disabled={current === total}
        className="w-9 h-9 rounded-lg border border-[#ddd6c8] text-sm flex items-center justify-center disabled:opacity-40 hover:bg-[#E8D8C4] transition-colors"
      >
        ›
      </button>
    </div>
  );
}

// ─── Modal ────────────────────────────────────────────────────────────────────

export function Modal({ title, children, onClose }: { title: string; children: ReactNode; onClose: () => void }) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={onClose}>
      <div className="bg-[#F7F2E8] rounded-2xl shadow-2xl w-full max-w-md" onClick={e => e.stopPropagation()}>
        <div className="flex items-center justify-between p-6 border-b border-[#ddd6c8]">
          <h3 className="font-display text-xl font-semibold text-[#243B32]">{title}</h3>
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-[#E8D8C4] text-[#6b7280] transition-colors">✕</button>
        </div>
        <div className="p-6">{children}</div>
      </div>
    </div>
  );
}

// ─── Empty state ──────────────────────────────────────────────────────────────

export function EmptyState({ icon, title, description, action }: {
  icon: string; title: string; description: string; action?: ReactNode;
}) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-8 text-center">
      <div className="w-16 h-16 rounded-2xl bg-[#E8D8C4] flex items-center justify-center text-3xl mb-4">{icon}</div>
      <h3 className="font-display text-xl font-semibold text-[#243B32] mb-2">{title}</h3>
      <p className="text-[#6b7280] text-sm max-w-xs mb-6">{description}</p>
      {action}
    </div>
  );
}

// ─── Stats card ───────────────────────────────────────────────────────────────

export function StatCard({ label, value, icon, trend }: { label: string; value: string; icon: string; trend?: string }) {
  return (
    <Card className="p-5">
      <div className="flex items-start justify-between mb-3">
        <span className="text-[#6b7280] text-sm font-medium">{label}</span>
        <span className="text-xl">{icon}</span>
      </div>
      <p className="font-display text-3xl font-semibold text-[#243B32]">{value}</p>
      {trend && <p className="text-xs text-[#83946A] mt-1 font-medium">{trend}</p>}
    </Card>
  );
}
