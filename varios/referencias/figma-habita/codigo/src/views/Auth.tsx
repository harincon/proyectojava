import { useState } from "react";
import Logo from "../components/Logo";
import { Btn, Input, Alert } from "../components/ui";

interface AuthProps {
  onNavigate: (view: string, extra?: object) => void;
}

export default function Auth({ onNavigate }: AuthProps) {
  const [mode, setMode] = useState<"login" | "register">("login");
  const [role, setRole] = useState<"cliente" | "inmobiliaria">("cliente");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [nombre, setNombre] = useState("");
  const [empresa, setEmpresa] = useState("");
  const [error, setError] = useState("");

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!email || !password) {
      setError("Por favor completa todos los campos obligatorios.");
      return;
    }
    setError("");
    if (role === "inmobiliaria") {
      onNavigate("agency");
    } else {
      onNavigate("client");
    }
  }

  return (
    <div className="min-h-screen bg-[#243B32] flex">
      {/* Left panel */}
      <div className="hidden lg:flex lg:w-1/2 flex-col justify-between p-14 relative overflow-hidden">
        <div
          className="absolute inset-0 opacity-20"
          style={{
            backgroundImage: `url(https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=1000&fit=crop&auto=format)`,
            backgroundSize: "cover",
            backgroundPosition: "center",
          }}
        />
        <div className="absolute inset-0 bg-gradient-to-b from-[#243B32]/50 via-transparent to-[#243B32]/80" />
        <div className="relative">
          <button onClick={() => onNavigate("home")}>
            <Logo size="lg" variant="light" />
          </button>
        </div>
        <div className="relative">
          <blockquote className="font-display text-3xl text-[#F7F2E8] leading-snug italic mb-6">
            "Encontramos nuestro hogar en menos de dos semanas. El proceso fue increíblemente sencillo."
          </blockquote>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-[#C96E4B] flex items-center justify-center text-white font-semibold">S</div>
            <div>
              <p className="text-[#F7F2E8] font-medium text-sm">Sara Montoya</p>
              <p className="text-[#E8D8C4]/60 text-xs">Medellín · Cliente desde 2025</p>
            </div>
          </div>
        </div>
      </div>

      {/* Right panel */}
      <div className="flex-1 bg-[#F7F2E8] flex flex-col justify-center px-8 lg:px-16 py-12">
        <div className="max-w-md w-full mx-auto">
          <div className="lg:hidden mb-8">
            <button onClick={() => onNavigate("home")}>
              <Logo size="md" variant="dark" />
            </button>
          </div>

          {/* Mode tabs */}
          <div className="flex rounded-xl border border-[#ddd6c8] overflow-hidden mb-8 bg-white">
            {(["login", "register"] as const).map(m => (
              <button
                key={m}
                onClick={() => { setMode(m); setError(""); }}
                className={`flex-1 py-3 text-sm font-medium transition-all ${mode === m ? "bg-[#243B32] text-[#F7F2E8]" : "text-[#6b7280] hover:text-[#252525]"}`}
              >
                {m === "login" ? "Iniciar sesión" : "Crear cuenta"}
              </button>
            ))}
          </div>

          <h1 className="font-display text-3xl font-semibold text-[#243B32] mb-1">
            {mode === "login" ? "Bienvenido de vuelta" : "Crea tu cuenta"}
          </h1>
          <p className="text-[#6b7280] text-sm mb-8">
            {mode === "login" ? "Ingresa a tu cuenta Habita." : "Únete a la comunidad Habita."}
          </p>

          {/* Role selector (only on register) */}
          {mode === "register" && (
            <div className="mb-6">
              <p className="text-sm font-medium text-[#252525] mb-3">Tipo de cuenta</p>
              <div className="grid grid-cols-2 gap-3">
                {([
                  { val: "cliente", label: "Soy cliente", desc: "Busco comprar o arrendar", icon: "🔍" },
                  { val: "inmobiliaria", label: "Soy inmobiliaria", desc: "Publico propiedades", icon: "🏢" },
                ] as const).map(opt => (
                  <button
                    key={opt.val}
                    onClick={() => setRole(opt.val)}
                    className={`p-4 rounded-xl border-2 text-left transition-all ${role === opt.val ? "border-[#C96E4B] bg-[#C96E4B]/5" : "border-[#ddd6c8] bg-white hover:border-[#83946A]"}`}
                  >
                    <div className="text-2xl mb-1.5">{opt.icon}</div>
                    <p className="text-sm font-semibold text-[#252525]">{opt.label}</p>
                    <p className="text-xs text-[#6b7280] mt-0.5">{opt.desc}</p>
                  </button>
                ))}
              </div>
            </div>
          )}

          {error && <div className="mb-5"><Alert type="error" message={error} /></div>}

          <form onSubmit={handleSubmit} className="space-y-4">
            {mode === "register" && (
              <>
                <Input
                  label="Nombre completo"
                  placeholder="Laura Rodríguez"
                  value={nombre}
                  onChange={e => setNombre(e.target.value)}
                />
                {role === "inmobiliaria" && (
                  <Input
                    label="Nombre de la empresa"
                    placeholder="Inmobiliaria XYZ S.A.S."
                    value={empresa}
                    onChange={e => setEmpresa(e.target.value)}
                  />
                )}
              </>
            )}
            <Input
              label="Correo electrónico"
              type="email"
              placeholder="correo@ejemplo.com"
              value={email}
              onChange={e => setEmail(e.target.value)}
            />
            <Input
              label="Contraseña"
              type="password"
              placeholder={mode === "register" ? "Mínimo 8 caracteres" : "Tu contraseña"}
              value={password}
              onChange={e => setPassword(e.target.value)}
            />
            {mode === "register" && (
              <Input label="Confirmar contraseña" type="password" placeholder="Repite la contraseña" />
            )}

            {mode === "login" && (
              <div className="flex justify-end">
                <button type="button" className="text-sm text-[#C96E4B] hover:underline">
                  ¿Olvidaste tu contraseña?
                </button>
              </div>
            )}

            <Btn type="submit" className="w-full mt-2" size="lg">
              {mode === "login" ? "Ingresar a mi cuenta" : "Crear cuenta gratis"}
            </Btn>
          </form>

          <div className="relative flex items-center gap-4 my-6">
            <div className="flex-1 h-px bg-[#ddd6c8]" />
            <span className="text-xs text-[#6b7280]">o continúa con</span>
            <div className="flex-1 h-px bg-[#ddd6c8]" />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <button className="flex items-center justify-center gap-2 px-4 py-3 rounded-xl border border-[#ddd6c8] bg-white text-sm font-medium hover:border-[#83946A] transition-colors">
              <span className="text-base">G</span> Google
            </button>
            <button className="flex items-center justify-center gap-2 px-4 py-3 rounded-xl border border-[#ddd6c8] bg-white text-sm font-medium hover:border-[#83946A] transition-colors">
              <span className="text-base">f</span> Facebook
            </button>
          </div>

          <p className="text-center text-sm text-[#6b7280] mt-6">
            {mode === "login" ? "¿Aún no tienes cuenta? " : "¿Ya tienes cuenta? "}
            <button
              className="text-[#C96E4B] font-medium hover:underline"
              onClick={() => { setMode(mode === "login" ? "register" : "login"); setError(""); }}
            >
              {mode === "login" ? "Crear cuenta" : "Inicia sesión"}
            </button>
          </p>

          {/* Admin shortcut */}
          <div className="mt-6 pt-6 border-t border-[#ddd6c8] text-center">
            <button
              className="text-xs text-[#6b7280] hover:text-[#C96E4B] transition-colors"
              onClick={() => onNavigate("admin")}
            >
              Acceso administración →
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
