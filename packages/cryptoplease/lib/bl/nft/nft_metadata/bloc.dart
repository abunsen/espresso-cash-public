import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cryptoplease/bl/processing_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solana/metaplex.dart';

part 'bloc.freezed.dart';
part 'event.dart';
part 'state.dart';

class NftMetadataBloc extends Bloc<NftMetadataEvent, NftMetadataState> {
  NftMetadataBloc() : super(const NftMetadataState()) {
    on<NftMetadataEvent>(_handler, transformer: sequential());
  }

  EventHandler<NftMetadataEvent, NftMetadataState> get _handler =>
      (e, emit) => e.map(
            initialized: (e) => _onInitialized(e, emit),
          );

  Future<void> _onInitialized(
    NftMetadataEvent event,
    Emitter<NftMetadataState> emit,
  ) async {
    final metadata = event.metadata;

    try {
      final data = await metadata.getExternalJson();

      emit(
        state.copyWith(
          processingState: const ProcessingState.none(),
          data: data,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(processingState: ProcessingState.error(e)),
      );
    }
  }
}