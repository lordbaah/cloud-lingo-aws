import { HiTranslate } from 'react-icons/hi';

interface TranslationButtonProps {
  onClick: () => void;
  isLoading: boolean;
  disabled: boolean;
}

export function TranslationButton({
  onClick,
  isLoading,
  disabled,
}: TranslationButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled || isLoading}
      className={`flex items-center gap-2 px-8 py-3 rounded-lg font-medium transition-all duration-200 ${
        disabled || isLoading
          ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
          : 'bg-[#121063] text-white hover:bg-midnight/90 active:bg-midnight/80 shadow-md hover:shadow-lg'
      }`}
    >
      {isLoading ? (
        <>
          <div className="animate-spin rounded-full h-5 w-5 border-2 border-white border-t-transparent"></div>
          Translating...
        </>
      ) : (
        <>
          <HiTranslate className="w-5 h-5" />
          Translate
        </>
      )}
    </button>
  );
}
