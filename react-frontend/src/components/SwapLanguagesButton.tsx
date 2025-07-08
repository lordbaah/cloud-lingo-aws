import { HiSwitchHorizontal } from 'react-icons/hi';

interface SwapLanguagesButtonProps {
  onClick: () => void;
}

export function SwapLanguagesButton({ onClick }: SwapLanguagesButtonProps) {
  return (
    <button
      onClick={onClick}
      className="p-3 text-gray-600 hover:text-tahiti hover:bg-tahiti/10 rounded-lg transition-all duration-200 group"
      title="Swap languages"
    >
      <HiSwitchHorizontal className="w-5 h-5 group-hover:scale-110 transition-transform duration-200" />
    </button>
  );
}
