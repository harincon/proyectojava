interface LogoProps {
  size?: "sm" | "md" | "lg";
  variant?: "light" | "dark";
  iconOnly?: boolean;
}

export default function Logo({ size = "md", variant = "light", iconOnly = false }: LogoProps) {
  const dims = { sm: 28, md: 36, lg: 48 };
  const textSizes = { sm: "text-lg", md: "text-xl", lg: "text-2xl" };
  const d = dims[size];
  const iconColor = variant === "light" ? "#F7F2E8" : "#243B32";
  const roofColor = variant === "light" ? "#C96E4B" : "#C96E4B";
  const textColor = variant === "light" ? "text-[#F7F2E8]" : "text-[#243B32]";

  return (
    <div className="flex items-center gap-2.5 select-none">
      <svg width={d} height={d} viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
        {/* House roof as triangle */}
        <polygon points="18,3 33,16 3,16" fill={roofColor} />
        {/* House body */}
        <rect x="5" y="15" width="26" height="18" rx="1" fill={iconColor} fillOpacity={variant === "light" ? 0.15 : 0.12} stroke={iconColor} strokeWidth="0" />
        <rect x="5" y="15" width="26" height="18" rx="1" fill={variant === "light" ? "#243B32" : "#F7F2E8"} fillOpacity="0.08" />
        {/* H letter inside house */}
        <rect x="10" y="19" width="3" height="10" rx="0.5" fill={variant === "light" ? "#F7F2E8" : "#243B32"} />
        <rect x="23" y="19" width="3" height="10" rx="0.5" fill={variant === "light" ? "#F7F2E8" : "#243B32"} />
        <rect x="10" y="23" width="16" height="2.5" rx="0.5" fill={variant === "light" ? "#F7F2E8" : "#243B32"} />
      </svg>
      {!iconOnly && (
        <span className={`${textSizes[size]} ${textColor} font-display font-semibold tracking-tight leading-none`}>
          Habita
        </span>
      )}
    </div>
  );
}
